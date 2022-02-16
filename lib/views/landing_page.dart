import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lingua_ml/helper/landing_page_helper.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/views/image_detector/image_pick_from_file.dart';
import 'package:lingua_ml/views/image_detector/side_nav_options.dart';
import 'package:lingua_ml/views/translation/translator.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LnadingPageState createState() => _LnadingPageState();
}

class _LnadingPageState extends State<LandingPage> with LandingPageHelper {
  Future _speak(String languageCode, String text) async {
    await flutterTts.setLanguage(languageCode);
    var result = await flutterTts.speak(text);
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  bool isPlaying = false;
  bool isDownloadingModel = false;
  bool isTranslating = false;
  Future<void> ttranslate() async {
    setState(() {
      isTranslating = true;
    });
    languageModelService.checkIsDownloaded(chosenLanguageTranslateTo.code,
        isChecking: (bool f) async {
      setState(() {
        isDownloadingModel = !f;
      });
    });

    String x = await translateIt();
    setState(() {
      translatedController.text = x;
      isTranslating = false;
    });
  }

  void clearData() {
    setState(() {
      imageFile = null;
      controller.clear();
      translatedController.clear();
    });
  }

  @override
  void initState() {
    print("INIT");
    debouncer.obj.listen((String text) async {
      await ttranslate();
    });
    // searchOnChange.debounceTime(Duration(seconds: 1)).listen((queryString) {});
    super.initState();
  }

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
                      chosenLanguageTranslateFrom,
                      chosenLanguageTranslateTo,
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
              controller: scrollController,
              child: ListView(
                controller: scrollController,
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
                                value: chosenLanguageTranslateFrom,
                                items: dropdownMenuItems
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
                                onChanged: (val) async {
                                  if (val != null) {
                                    setState(
                                      () => chosenLanguageTranslateFrom = val,
                                    );
                                    await ttranslate();
                                    // searchOnChange.add(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final LanguageModel _temp =
                                chosenLanguageTranslateFrom;
                            final String _tempText = controller.text;
                            setState(() {
                              chosenLanguageTranslateFrom =
                                  chosenLanguageTranslateTo;
                              chosenLanguageTranslateTo = _temp;
                              controller.text = translatedController.text;
                              translatedController.text = _tempText;
                            });
                            await ttranslate();
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
                                value: chosenLanguageTranslateTo,
                                items: dropdownMenuItems
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
                                onChanged: (val) async {
                                  if (val != null) {
                                    setState(
                                      () => chosenLanguageTranslateTo = val,
                                    );
                                    await ttranslate();
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
                    toTranslate: chosenLanguageTranslateTo,
                    fromTranslate: chosenLanguageTranslateFrom,
                    recognisedText: (RecognisedText? texts) async {
                      if (texts != null) {
                        setState(() {
                          controller.text =
                              translationService.populateFirst(texts.blocks);
                        });
                        await ttranslate();
                        // String x = await translateIt();
                        // setState(() {
                        //   translatedController.text = x;
                        // });
                      }
                      setState(() {
                        recognisedText = texts;
                      });
                    },
                  ),
                  TranslationPage(
                    controller: controller,
                    translatedController: translatedController,
                    onTextChangedToTranslate: (text) {
                      debouncer.update(text);
                    },
                    // onPressedSpeak: () {},
                  ),
                  // if (recognisedText != null) ...{

                  // },
                ],
              ),
            ),
            // if (imageFile != null || controller.text.isNotEmpty) ...{
            Positioned(
              right: 10,
              bottom: 10,
              child: SideNavOptions(
                onClear: () {
                  clearData();
                },
                onPressedTranslate: isTranslating
                    ? null
                    : () async {
                        await ttranslate();
                      },
                onPressedSpeak: translatedController.text.isEmpty
                    ? null
                    : () async {
                        if (Platform.isIOS) {
                          await flutterTts.setIosAudioCategory(
                              IosTextToSpeechAudioCategory.ambient,
                              [
                                IosTextToSpeechAudioCategoryOptions
                                    .allowBluetooth,
                                IosTextToSpeechAudioCategoryOptions
                                    .allowBluetoothA2DP,
                                IosTextToSpeechAudioCategoryOptions
                                    .mixWithOthers
                              ],
                              IosTextToSpeechAudioMode.voicePrompt);
                        }
                        String code = "en-US";
                        switch (chosenLanguageTranslateTo.code) {
                          case "es":
                            code = "es-ES";
                            break;
                          case "zh":
                            code = "zh-CN";
                            break;
                          case "fr":
                            code = "fr-FR";
                            break;
                          case "hi":
                            code = "hi-IN";
                            break;
                          case "ja":
                            code = "ja-JP";
                            break;
                          case "ko":
                            code = "ko-KR";
                            break;
                          default:
                            code = 'en-US';
                            break;
                        }
                        if (!isPlaying) {
                          setState(() {
                            isPlaying = true;
                          });
                          await flutterTts.awaitSpeakCompletion(true);
                          await _speak(code, translatedController.text);
                        } else {
                          flutterTts.stop();
                          setState(() {
                            isPlaying = false;
                          });
                        }
                      },
              ),
            ),
            isDownloadingModel
                ? Container(
                    width: size.width,
                    height: size.height,
                    color: Colors.white.withOpacity(.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Downloading Model...",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container()
            // },
          ],
        ),
      ),
    );
  }
}
