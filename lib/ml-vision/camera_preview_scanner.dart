// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:throttling/throttling.dart';

import 'detector_painters.dart';
import 'scanner_utils.dart';
import 'package:http/http.dart' as http;

class CameraPreviewScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> {
  VisionText _scanResults;
  // TODO: Map a Vision Text block to a translated block
  Map<String, String> _translatedBlocks;
  CameraController _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  final Throttling thr = new Throttling(duration: Duration(seconds: 2));
  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();
  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final ImageLabeler _cloudImageLabeler =
      FirebaseVision.instance.cloudImageLabeler();
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  final TextRecognizer _cloudRecognizer =
      FirebaseVision.instance.cloudTextRecognizer();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _processResults(VisionText results) async {
    final translationsMap = HashMap<String, String>();

    if (this._scanResults != null) {
      for (TextBlock block in this._scanResults.blocks) {
        final blockMd5 = md5.convert(utf8.encode(block.text)).toString();

        if (translationsMap.containsKey(blockMd5)) {
          continue;
        }
        try {
          final result = await http
              .get(
                  "https://translation.googleapis.com/language/translate/v2?target=ro&key=AIzaSyAACkuzu-1_YyBtL09iudWae90IZa6Y5cs&q=" +
                      block.text)
              .timeout(Duration(milliseconds: 400));

          final jsonResult = json.decode(result.body);

          final translation = jsonResult['data']['translations'][0]
                  ['translatedText']
              .toString();
          translationsMap[blockMd5] = translation;
        } catch (error) {
          logger.e('Could not translate detection: ' + block.text);
          logger.e(error);
        }
      }
    }

    setState(() {
      _scanResults = results;
      _translatedBlocks = translationsMap;
    });
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
        description,
        // defaultTargetPlatform == TargetPlatform.iOS
        //     ? ResolutionPreset.low
        //     : ResolutionPreset.high,
        ResolutionPreset.low);
    await _camera.initialize();

    DateTime scanStartedAt, scanFinishedAt;

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) {
        // logger.d('scanner busy...');
        return;
      }

      setState(() {
        _isDetecting = true;
      });
      scanStartedAt = DateTime.now();

      _recognizer
          .processImage(FirebaseVisionImage.fromBytes(
        ScannerUtils.concatenatePlanes(image.planes),
        ScannerUtils.buildMetaData(
            image,
            ScannerUtils.rotationIntToImageRotation(
                description.sensorOrientation)),
      ))
          .then((VisionText results) {
        if (results == null ||
            results.text == null ||
            results.text.trim() == '') return;

        logger.d('results text: ');
        logger.d(results.text);

        // build the block translations
        thr.throttle(() {
          logger.i('Processing results: ' + DateTime.now().toString());
          _processResults(results);
        });
        // print('detecting finished: ' + DateTime.now().toIso8601String());
      }).catchError((error) {
        setState(() {
          _scanResults = null;
          _translatedBlocks = HashMap<String, String>();
        });

        logger.e('detection thrown an error: ');
        logger.e(error);
      }).whenComplete(() {
        setState(() {
          _isDetecting = false;
        });
        scanFinishedAt = DateTime.now();
        logger.d('detecting took: ' +
            scanFinishedAt.difference(scanStartedAt).inMilliseconds.toString() +
            " millis");
      });
    });
  }

  Widget _buildResults() {
    const Text noResultsText = Text('No results!');

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;

    

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
  
    

    painter = TextDetectorPainter(imageSize, _scanResults, _translatedBlocks);
    // }
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Vision Example'),
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              // _currentDetector = result;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
              const PopupMenuItem<Detector>(
                child: Text('Detect Barcode'),
                value: Detector.barcode,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Face'),
                value: Detector.face,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Label'),
                value: Detector.label,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Cloud Label'),
                value: Detector.cloudLabel,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Text'),
                value: Detector.text,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Cloud Text'),
                value: Detector.cloudText,
              ),
            ],
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _barcodeDetector.close();
      _faceDetector.close();
      _imageLabeler.close();
      _cloudImageLabeler.close();
      _recognizer.close();
      _cloudRecognizer.close();
    });

    super.dispose();
  }
}
