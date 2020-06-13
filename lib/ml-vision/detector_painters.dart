// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/translator.dart';

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
  TextDetectorPainter(this.absoluteImageSize, this.visionText);

  final Size absoluteImageSize;
  final VisionText visionText;
  final logger = Logger();

  GoogleTranslator translator = new GoogleTranslator();
  @override
  void paint(Canvas canvas, Size size) async {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        try {
          String text;
          paint.style = PaintingStyle.fill;
          paint.color = Colors.white;
          try {
            final x =
                await translator.translate(line.text, from: 'ro', to: 'en');
            text = x;
          } catch (ex) {
            logger.e('Could not translate text: ' + line.text);
            logger.e(ex);
          }

          logger.i('Translated text: ' + line.text + ' to: ' + text);
          canvas.drawRect(scaleRect(line), paint);
          TextSpan textSpan = new TextSpan(
              style: new TextStyle(
                  color: new Color.fromRGBO(0, 0, 0, 1.0),
                  fontSize: 16,
                  fontFamily: 'Roboto'),
              text: text);
          TextPainter tp = new TextPainter(
              text: textSpan,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(
              canvas,
              new Offset(line.boundingBox.left * scaleX,
                  line.boundingBox.top * scaleY));
        } on Exception catch (ex) {
          logger.e('Could not paint the translated text:');
          logger.e(ex);
        } catch (unknownEx) {
          logger.e('Could not paint the translated text: UNKNOWN_EXCEPTION');
        }
      }

      // paint.style = PaintingStyle.fill;
      // paint.color = Colors.white;
      // translator
      //     .translate(block.text, from: 'ro', to: 'en')
      //     .then((x) => {text = x});
      // canvas.drawRect(scaleRect(block), paint);
      // TextSpan textSpan = new TextSpan(
      //     style: new TextStyle(
      //         color: new Color.fromRGBO(0, 0, 0, 1.0),
      //         fontSize: 16,
      //         fontFamily: 'Roboto'),
      //     text: text);
      // TextPainter tp = new TextPainter(
      //     text: textSpan,
      //     textAlign: TextAlign.left,
      //     textDirection: TextDirection.ltr);
      // tp.layout();
      // tp.paint(
      //     canvas,
      //     new Offset(
      //         block.boundingBox.left * scaleX, block.boundingBox.top * scaleY));
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.visionText != visionText;
  }
}
