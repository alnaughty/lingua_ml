import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingua_ml/global/dropdown_holders.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/services/translate_service.dart';
import 'package:lingua_ml/views/image_detector/image_pick_from_file.dart';
import 'package:lingua_ml/views/image_detector/side_nav_options.dart';
import 'package:lingua_ml/views/translation/translator.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LnadingPageState createState() => _LnadingPageState();
}

class _LnadingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final DropdownHolders _drpdwnHolder = DropdownHolders();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  final TranslateService _translationService = TranslateService();
  // ignore: prefer_final_fields
  late LanguageModel _chosenLanguageTranslateFrom = _drpdwnHolder.languages
      .where((element) => element.name == "English")
      .first;
  // ignore: prefer_final_fields
  late LanguageModel _chosenLanguageTranslateTo = _drpdwnHolder.languages
      .where((element) => element.name == "French")
      .first;

  late final List<LanguageModel> _dropdownMenuItems = Platform.isIOS
      ? _drpdwnHolder.languages
          .where((element) => element.iosAvailable)
          .toList()
      : _drpdwnHolder.languages;

  File? imageFile;
  RecognisedText? recognisedText;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: const Text("Lingua App - ML Kit"),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: "Live Stream",
              onPressed: () {
                if (Platform.isAndroid) {
                  Navigator.pushNamed(
                    context,
                    "/text_detector_v2",
                    arguments: <LanguageModel>[
                      _chosenLanguageTranslateFrom,
                      _chosenLanguageTranslateTo,
                    ],
                  );
                } else {
                  Navigator.pushNamed(context, "/text_detector");
                }
              },
              icon: const Icon(
                Icons.live_tv,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: [
                  SizedBox(
                    width: size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.only(
                              left: 10,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<LanguageModel>(
                                isExpanded: true,
                                value: _chosenLanguageTranslateFrom,
                                items: _dropdownMenuItems
                                    .map(
                                      (LanguageModel e) =>
                                          DropdownMenuItem<LanguageModel>(
                                        value: e,
                                        child: Text(
                                          e.name,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(
                                      () => _chosenLanguageTranslateFrom = val,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final LanguageModel _temp =
                                _chosenLanguageTranslateFrom;
                            setState(() {
                              _chosenLanguageTranslateFrom =
                                  _chosenLanguageTranslateTo;
                              _chosenLanguageTranslateTo = _temp;
                            });
                          },
                          icon: const Icon(Icons.swap_horiz_rounded),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.only(
                              left: 10,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<LanguageModel>(
                                isExpanded: true,
                                value: _chosenLanguageTranslateTo,
                                items: _dropdownMenuItems
                                    .map(
                                      (LanguageModel e) =>
                                          DropdownMenuItem<LanguageModel>(
                                        value: e,
                                        child: Text(
                                          e.name,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(
                                      () => _chosenLanguageTranslateTo = val,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ImagePickFromFile(
                    onPickFile: (File pickedFil) =>
                        setState(() => imageFile = pickedFil),
                    imageFile: imageFile,
                    toTranslate: _chosenLanguageTranslateTo,
                    fromTranslate: _chosenLanguageTranslateFrom,
                    recognisedText: (RecognisedText? texts) async {
                      if (texts != null) {
                        setState(() {
                          _controller.text =
                              _translationService.populateFirst(texts.blocks);
                        });
                        String translatedText = await _translationService.init(
                          _controller.text,
                          source: _chosenLanguageTranslateFrom.translateTo,
                          target: _chosenLanguageTranslateTo.translateTo,
                        );
                        setState(() {
                          _translatedController.text = translatedText;
                        });
                      }
                      setState(() {
                        recognisedText = texts;
                      });
                    },
                  ),
                  if (recognisedText != null) ...{
                    TranslationPage(
                      controller: _controller,
                      translatedController: _translatedController,
                    ),
                  },
                  // if (imageFile != null) ...{
                  //   const SizedBox(
                  //     height: 20,
                  //   ),
                  //   Image.file(imageFile!),

                  // } else ...{

                  // },
                ],
              ),
            ),
            if (imageFile != null) ...{
              // const Positioned(
              //   right: 10,
              //   bottom: 10,
              //   child: SideNavOptions(),
              // ),
            },
          ],
        ),
      ),
    );
  }
}
