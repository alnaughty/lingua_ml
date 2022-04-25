import 'package:flutter/material.dart';
import 'package:lingua_ml/helper/debouncer.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({
    Key? key,
    required this.controller,
    required this.translatedController,
    required this.onTextChangedToTranslate,
    this.disableTextEditing = false,
  }) : super(key: key);
  final TextEditingController controller;
  final TextEditingController translatedController;
  final Function(String)? onTextChangedToTranslate;
  final bool disableTextEditing;
  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final ScrollController _resultController = ScrollController();
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
                enabled: !widget.disableTextEditing,
                controller: widget.controller,
                onChanged: widget.onTextChangedToTranslate,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  hintText: "Enter text here",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: size.width,
              height: 100,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black38,
                ),
              ),
              child: Scrollbar(
                controller: _resultController,
                child: SingleChildScrollView(
                  controller: _resultController,
                  child: Text(
                    widget.translatedController.text,
                  ),
                ),
              ),
              // child: ,
              // child: TextField(
              //   enabled: true,
              //   enableInteractiveSelection: true,
              //   minLines: 4,
              //   maxLines: 6,
              //   controller: widget.translatedController,
              //   decoration: const InputDecoration(
              //     contentPadding:
              //         EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              //     border: OutlineInputBorder(),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
