import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lingua_ml/global/dropdown_holders.dart';
import 'package:lingua_ml/helper/debouncer.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/services/language_model_service.dart';
import 'package:lingua_ml/services/translate_service.dart';

class LandingPageHelper {
  LandingPageHelper._singleton();
  static final LandingPageHelper _instance = LandingPageHelper._singleton();
  static LandingPageHelper get instance => _instance;
  // final BehaviorSubject<String> searchOnChange = BehaviorSubject<String>();
  final FlutterTts flutterTts = FlutterTts();
  final Debouncer debouncer = Debouncer.instance;
  final ScrollController scrollController = ScrollController();
  final DropdownHolders drpdwnHolder = DropdownHolders();
  final TextEditingController controller = TextEditingController();
  final TextEditingController translatedController = TextEditingController();
  final TranslateService translationService = TranslateService();
  final LanguageModelService languageModelService =
      LanguageModelService.instance;
  // ignore: prefer_final_fields
  late LanguageModel chosenLanguageTranslateFrom = drpdwnHolder.languages
      .where((element) => element.name == "English")
      .first;
  // ignore: prefer_final_fields
  late LanguageModel chosenLanguageTranslateTo =
      drpdwnHolder.languages.where((element) => element.name == "French").first;

  late final List<LanguageModel> dropdownMenuItems = Platform.isIOS
      ? drpdwnHolder.languages.where((element) => element.iosAvailable).toList()
      : drpdwnHolder.languages;
  Future<String> translateIt() async {
    String translatedText = await translationService.init(
      controller.text,
      source: chosenLanguageTranslateFrom.translateTo,
      target: chosenLanguageTranslateTo.translateTo,
    );
    return translatedText;
    // setState(() {
    //   _translatedController.text = translatedText;
    // });
  }

  Future<String> manualTranslate(String text,
      {required LanguageModel from, required LanguageModel to}) async {
    return await translationService.init(
      text,
      source: from.translateTo,
      target: to.translateTo,
    );
  }
}
