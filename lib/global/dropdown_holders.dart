import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lingua_ml/models/language_model.dart';

class DropdownHolders {
  final List<LanguageModel> languages = [
    const LanguageModel(
      name: "Chinese",
      code: "zh",
      option: TextRecognitionOptions.CHINESE,
      fontFamily: "CHINESE",
      iosAvailable: false,
      translateTo: TranslateLanguage.CHINESE,
    ),
    const LanguageModel(
      name: "English",
      code: "en",
      translateTo: TranslateLanguage.ENGLISH,
    ),
    const LanguageModel(
      name: "French",
      code: "fr",
      translateTo: TranslateLanguage.FRENCH,
    ),
    const LanguageModel(
      name: "Hindi",
      code: "hi",
      option: TextRecognitionOptions.DEVANAGIRI,
      fontFamily: "DEVANAGIRI",
      iosAvailable: false,
      translateTo: TranslateLanguage.HINDI,
    ),
    const LanguageModel(
      name: "Japanese",
      code: "ja",
      option: TextRecognitionOptions.JAPANESE,
      fontFamily: "JAPANESE",
      iosAvailable: false,
      translateTo: TranslateLanguage.JAPANESE,
    ),
    const LanguageModel(
      name: "Korean",
      code: "ko",
      option: TextRecognitionOptions.KOREAN,
      fontFamily: "KOREAN",
      iosAvailable: false,
      translateTo: TranslateLanguage.KOREAN,
    ),
    const LanguageModel(
      name: "Spanish",
      code: "es",
      translateTo: TranslateLanguage.SPANISH,
    ),
    const LanguageModel(
      name: "Waray",
      code: "wr",
      translateTo: "wr",
    )
  ];
}
