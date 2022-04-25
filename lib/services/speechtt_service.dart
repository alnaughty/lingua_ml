import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechTT {
  final SpeechToText speechToText = SpeechToText();
  SpeechTT._singleton();
  static final SpeechTT _instance = SpeechTT._singleton();
  static SpeechTT get instance => _instance;
  void errorListener(SpeechRecognitionError error,
      {required ValueChanged<String> message}) {
    print(
        'Received error status: $error, listening: ${speechToText.isListening}');
    message('${error.errorMsg} - ${error.permanent}');
  }

  void statusListener(String status,
      {required ValueChanged<String> result}) async {
    print(
        'Received listener status: $status, listening: ${speechToText.isListening}');
    result(status);
  }

  void resultListener(SpeechRecognitionResult result,
      {required ValueChanged<String> finalResult,
      required ValueChanged<String> listenedWords}) async {
    print(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');

    listenedWords(result.recognizedWords);
    if (result.finalResult) {
      finalResult(result.recognizedWords);
    }
  }

  String getLocale(String localeCode) {
    String code = "";
    switch (localeCode) {
      case "es":
        code = "es_ES";
        break;
      case "zh":
        code = "zh_CN";
        break;
      case "fr":
        code = "fr_FR";
        break;
      case "hi":
        code = "hi_IN";
        break;
      case "ja":
        code = "ja_JP";
        break;
      case "ko":
        code = "ko_KR";
        break;
      default:
        code = 'en_US';
        break;
    }
    return code;
    // setState(() {
    //   _currentLocaleId = code;
    // });
  }
}
