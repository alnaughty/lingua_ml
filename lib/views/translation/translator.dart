import 'package:flutter/material.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({
    Key? key,
    required this.controller,
    required this.translatedController,
  }) : super(key: key);
  final TextEditingController controller;
  final TextEditingController translatedController;
  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  // final TextEditingController _controller = TextEditingController();
  // final TextEditingController _translatedController = TextEditingController();
  // late final _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
  //   sourceLanguage: widget.fromLanguage.translateTo,
  //   targetLanguage: widget.toLanguage.translateTo,
  // );

  @override
  void initState() {
    // populateFirst();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // _controller.text = populateFirst();
    return Material(
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: size.width,
              child: TextField(
                minLines: 4,
                maxLines: 6,
                controller: widget.controller,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: size.width,
              child: TextField(
                enabled: true,
                enableInteractiveSelection: true,
                minLines: 4,
                maxLines: 6,
                controller: widget.translatedController,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
