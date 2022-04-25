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

class _LnadingPageState extends State<LandingPage> {
  final LandingPageHelper _helper = LandingPageHelper.instance;
  Future _speak(String languageCode, String text) async {
    await _helper.flutterTts.setLanguage(languageCode);
    var result = await _helper.flutterTts.speak(text);
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  bool isPlaying = false;
  bool isDownloadingModel = false;
  bool isTranslating = false;
  Future<void> ttranslate() async {
    setState(() {
      isTranslating = true;
    });
    _helper.languageModelService.checkIsDownloaded(
        _helper.chosenLanguageTranslateTo.code, isChecking: (bool f) async {
      setState(() {
        isDownloadingModel = !f;
      });
    });

    String x = await _helper.translateIt();
    setState(() {
      _helper.translatedController.text = x;
      isTranslating = false;
    });
  }

  void clearData() {
    setState(() {
      imageFile = null;
      _helper.controller.clear();
      _helper.translatedController.clear();
    });
  }

  @override
  void initState() {
    print("INIT");
    _helper.debouncer.obj.listen((String text) async {
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
                      _helper.chosenLanguageTranslateFrom,
                      _helper.chosenLanguageTranslateTo,
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
              controller: _helper.scrollController,
              child: ListView(
                controller: _helper.scrollController,
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
                                value: _helper.chosenLanguageTranslateFrom,
                                items: _helper.dropdownMenuItems
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
                                      () => _helper
                                          .chosenLanguageTranslateFrom = val,
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
                                _helper.chosenLanguageTranslateFrom;
                            final String _tempText = _helper.controller.text;
                            setState(() {
                              _helper.chosenLanguageTranslateFrom =
                                  _helper.chosenLanguageTranslateTo;
                              _helper.chosenLanguageTranslateTo = _temp;
                              _helper.controller.text =
                                  _helper.translatedController.text;
                              _helper.translatedController.text = _tempText;
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
                                value: _helper.chosenLanguageTranslateTo,
                                items: _helper.dropdownMenuItems
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
                                      () => _helper.chosenLanguageTranslateTo =
                                          val,
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
                    toTranslate: _helper.chosenLanguageTranslateTo,
                    fromTranslate: _helper.chosenLanguageTranslateFrom,
                    recognisedText: (RecognisedText? texts) async {
                      if (texts != null) {
                        setState(() {
                          _helper.controller.text = _helper.translationService
                              .populateFirst(texts.blocks);
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
                    controller: _helper.controller,
                    translatedController: _helper.translatedController,
                    onTextChangedToTranslate: (text) {
                      _helper.debouncer.update(text);
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
                onPressedSpeak: _helper.translatedController.text.isEmpty
                    ? null
                    : () async {
                        if (Platform.isIOS) {
                          await _helper.flutterTts.setIosAudioCategory(
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
                        switch (_helper.chosenLanguageTranslateTo.code) {
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
                          await _helper.flutterTts.awaitSpeakCompletion(true);
                          await _speak(code, _helper.translatedController.text);
                        } else {
                          _helper.flutterTts.stop();
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
