import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LanguageModelService {
  LanguageModelService._internal();
  static final LanguageModelService _instance =
      LanguageModelService._internal();
  static LanguageModelService get instance => _instance;

  final TranslateLanguageModelManager _languageModelManager =
      GoogleMlKit.nlp.translateLanguageModelManager();
  void checkIsDownloaded(String code,
      {required ValueChanged<bool> isChecking}) async {
    print("Checking");
    await isModelDownloaded(code, (f) {
      isChecking(!f);
    });
    // await isModelDownloaded(widget.toModel.code, (f) {
    //   setState(() => isChecking2 = f);
    // });
  }

  Future<void> isModelDownloaded(
      String code, ValueChanged<bool> onFinish) async {
    await _languageModelManager.isModelDownloaded(code).then((value) async {
      print("DOWNLOADED: $value");
      if (value) {
        onFinish(false);
      } else {
        onFinish(true);
        await downloadModel(code).whenComplete(() => onFinish(false));
      }
    });
  }

  Future<void> downloadModel(String code) async {
    await _languageModelManager.downloadModel(code);
    return;
  }
}
