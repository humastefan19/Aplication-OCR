import 'dart:collection';
import 'dart:core';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class TranslationUtils {
  static Logger _logger = new Logger();

  static Future<Map<String, String>> translateBlocks(
      VisionText scanResults) async {
    if (scanResults == null) {
      return null;
    }
    final translationsMap = HashMap<String, String>();
    for (TextBlock block in scanResults.blocks) {
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

        final translation =
            jsonResult['data']['translations'][0]['translatedText'].toString();
        translationsMap[blockMd5] = translation;
      } catch (error) {
        _logger.e('Could not translate block: ' + block.text);
        _logger.e(error);
      }
    }
    return translationsMap;
  }

  static Future<String> translateText(VisionText scanResults) async {
    if (scanResults == null) {
      return null;
    }
    try {
      final result = await http
          .get(
              "https://translation.googleapis.com/language/translate/v2?target=ro&key=AIzaSyAACkuzu-1_YyBtL09iudWae90IZa6Y5cs&q=" +
                  scanResults.text)
          .timeout(Duration(milliseconds: 2000));

      final jsonResult = json.decode(result.body);

      final translation =
          jsonResult['data']['translations'][0]['translatedText'].toString();
      return translation;
    } catch (error) {
      _logger.e('Could not translate text: ' + scanResults.text);
      _logger.e(error);
      return null;
    }
  }
}
