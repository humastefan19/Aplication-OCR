// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import 'detector_painters.dart';
import 'scanner_utils.dart';

class CameraPreviewScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> {
  VisionText _scanResults;
  CameraController _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();
  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final ImageLabeler _cloudImageLabeler =
      FirebaseVision.instance.cloudImageLabeler();
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  final TextRecognizer _cloudRecognizer =
      FirebaseVision.instance.cloudTextRecognizer();
  final GoogleTranslator translator = new GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.high,
    );
    await _camera.initialize();

    DateTime scanStartedAt, scanFinishedAt;

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) {
        print('scanner busy...');
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

        

        setState(() async {
          for (TextBlock block in results.blocks) {
            block.text = await translator.translate(block.text,to:'en',from:'ro');
            for (TextLine line in block.lines) {
              line.text = await translator.translate(line.text,to:'en',from:'ro');
              for (TextElement element in line.elements) {
                element.text = await translator.translate(element.text,to:'en',from:'ro');
              }
            }
          }
          
          _scanResults = results;
          print('results text: ');
          print(results.text);
        });
        // _isDetecting = false;
        // print('detecting finished: ' + DateTime.now().toIso8601String());
      }).catchError((error) {
        print('detection thrown an error: ');
        print(error);
      }).whenComplete(() {
        setState(() {
          _isDetecting = false;
        });
        scanFinishedAt = DateTime.now();
        print('detecting took: ' +
            scanFinishedAt.difference(scanStartedAt).inMilliseconds.toString() +
            " millis");
      });

      // ScannerUtils.detect(
      //   image: image,
      //   detectInImage: _getDetectionMethod(),
      //   imageRotation: description.sensorOrientation,
      // ).then(
      //   (VisionText results) {
      //     // if (_currentDetector == null) return;
      //     print('results text: ');
      //     print(results.text);
      //     setState(() {
      //       _scanResults = results;
      //     });
      //   },
      // ).whenComplete(() => _isDetecting = false);
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
    GoogleTranslator translator;
    

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
  
    

    // switch (_currentDetector) {
    // case Detector.barcode:
    //   if (_scanResults is! List<Barcode>) return noResultsText;
    //   painter = BarcodeDetectorPainter(imageSize, _scanResults);
    //   break;
    // case Detector.face:
    //   if (_scanResults is! List<Face>) return noResultsText;
    //   painter = FaceDetectorPainter(imageSize, _scanResults);
    //   break;
    // case Detector.label:
    //   if (_scanResults is! List<ImageLabel>) return noResultsText;
    //   painter = LabelDetectorPainter(imageSize, _scanResults);
    //   break;
    // case Detector.cloudLabel:
    //   if (_scanResults is! List<ImageLabel>) return noResultsText;
    //   painter = LabelDetectorPainter(imageSize, _scanResults);
    //   break;
    // default:
    //   assert(_currentDetector == Detector.text ||
    //       _currentDetector == Detector.cloudText);
    //   if (_scanResults is! VisionText) return noResultsText;
    painter = TextDetectorPainter(imageSize, _scanResults);
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
