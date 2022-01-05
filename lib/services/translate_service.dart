import 'package:google_ml_kit/google_ml_kit.dart';

class TranslateService {
  Future<String> init(String text,
      {required String source, required String target}) async {
    print(text);
    final _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );
    return await _onDeviceTranslator.translateText(text);
  }

  String populateFirst(List<TextBlock> blocks) {
    String text = """""";
    for (TextBlock block in blocks) {
      text += (blocks.indexOf(block) == 0 ? "" : "\n") + block.text;
    }
    // translateText();
    return text;
  }
}
