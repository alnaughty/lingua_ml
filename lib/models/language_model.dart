import 'package:google_ml_kit/google_ml_kit.dart';

class LanguageModel {
  final String name;
  final String code;
  final TextRecognitionOptions option;
  final String fontFamily;
  final bool iosAvailable;
  final String translateTo;
  const LanguageModel({
    required this.name,
    required this.code,
    this.option = TextRecognitionOptions.DEFAULT,
    this.fontFamily = "DEFAULT",
    this.iosAvailable = true,
    required this.translateTo,
  });
}
