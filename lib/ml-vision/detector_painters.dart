// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

enum Detector { barcode, face, label, cloudLabel, text, cloudText }

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(this.absoluteImageSize, this.barcodeLocations);

  final Size absoluteImageSize;
  final List<Barcode> barcodeLocations;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(Barcode barcode) {
      return Rect.fromLTRB(
        barcode.boundingBox.left * scaleX,
        barcode.boundingBox.top * scaleY,
        barcode.boundingBox.right * scaleX,
        barcode.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (Barcode barcode in barcodeLocations) {
      paint.color = Colors.green;
      canvas.drawRect(scaleRect(barcode), paint);
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.barcodeLocations != barcodeLocations;
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces);

  final Size absoluteImageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}

class LabelDetectorPainter extends CustomPainter {
  LabelDetectorPainter(this.absoluteImageSize, this.labels);

  final Size absoluteImageSize;
  final List<ImageLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 23.0,
          textDirection: TextDirection.ltr),
    );

    builder.pushStyle(ui.TextStyle(color: Colors.green));
    for (ImageLabel label in labels) {
      builder.addText('Label: ${label.text}, '
          'Confidence: ${label.confidence.toStringAsFixed(2)}\n');
    }
    builder.pop();

    canvas.drawParagraph(
      builder.build()
        ..layout(ui.ParagraphConstraints(
          width: size.width,
        )),
      const Offset(0.0, 0.0),
    );
  }

  @override
  bool shouldRepaint(LabelDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.labels != labels;
  }
}

// Paints rectangles around all the text in the image.
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(
      this.absoluteImageSize, this.visionText, this.translatedBlocks);

  final Size absoluteImageSize;
  final VisionText visionText;
  final Map<String, String> translatedBlocks;
  final logger = Logger();

  GoogleTranslator translator = new GoogleTranslator();
  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      if (container == null) {
        throw new Exception("Null container");
      }

      double left = container.boundingBox.left * scaleX,
          top = container.boundingBox.top * scaleY,
          right = container.boundingBox.right * scaleX,
          bottom = container.boundingBox.bottom * scaleY;

      if (left == null || right == null || top == null || bottom == null) {
        throw new Exception("Invalid rect position!");
      }

      return Rect.fromLTRB(left, top, right, bottom);
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (TextBlock block in visionText.blocks) {
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white;
      try {
        canvas.drawRect(scaleRect(block), paint);
      } on Exception catch (ex) {
        logger.e("Could not paint canvas: ");
        logger.e(ex);
        continue;
      } catch (u) {
        logger.e("Unknown error while painting the canvas");
        continue;
      }

      try {
        // final result = await translator
        //     .translate(block.text, from: 'en', to: 'ro')
        //     .timeout(Duration(milliseconds: 700));

        // final result = await http
        //     .get(
        //         "https://translation.googleapis.com/language/translate/v2?target=ro&key=AIzaSyAACkuzu-1_YyBtL09iudWae90IZa6Y5cs&q=" +
        //             block.text)
        //     .timeout(Duration(milliseconds: 400));

        // final jsonResult = json.decode(result.body);

        // final translation =
        //     jsonResult['data']['translations'][0]['translatedText'].toString();

        final blockMd5 = md5.convert(utf8.encode(block.text)).toString();
        final translation = translatedBlocks[blockMd5];
        logger.i("Translation for ${block.text} is $translation");
        if (canvas == null || paint == null) {
          logger.e("Null canvas or paint");
          return;
        }

        final textSpan = new TextSpan(
            style: new TextStyle(
                color: new Color.fromRGBO(0, 0, 0, 1.0),
                fontSize: 16,
                fontFamily: 'Roboto'),
            text: translation == null ? block.text : translation);
        final tp = new TextPainter(
            text: textSpan,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            new Offset(block.boundingBox.left * scaleX,
                block.boundingBox.top * scaleY));
      } on TimeoutException catch (ex) {
        logger.e("timeout exception");
        logger.e(ex);
      } on Exception catch (ex) {
        logger.e('Could not translate text: ' + block.text);
        logger.e(ex);
      } catch (err) {
        logger.e("Unknown exception while translating text!");
      }
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.visionText != visionText;
  }
}

class TranslateResponse {
  TranslationsData data;

  TranslateResponse(this.data);
}

class TranslationsData {
  List<Translation> translations;

  TranslationsData(this.translations);
}

class Translation {
  String translatedText;
  String detectedSourceLanguage;

  Translation(this.translatedText, this.detectedSourceLanguage);

  Translation.fromJson(Map<String, dynamic> json)
      : translatedText = json['translatedText'],
        detectedSourceLanguage = json['detectedSourceLanguage'];

  Map<String, dynamic> toJson() => {
        'translatedText': translatedText,
        'detectedSourceLanguage': detectedSourceLanguage
      };
}
