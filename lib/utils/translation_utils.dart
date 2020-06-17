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
    if (scanResults != null) {
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

          final translation = jsonResult['data']['translations'][0]
                  ['translatedText']
              .toString();
          translationsMap[blockMd5] = translation;
        } catch (error) {
          _logger.e('Could not translate detection: ' + block.text);
          _logger.e(error);
        }
      }
      return translationsMap;
    }
  }
}
