import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lingua_ml/helper/landing_page_helper.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/services/speechtt_service.dart';
import 'package:lingua_ml/views/image_detector/image_pick_from_file.dart';
import 'package:lingua_ml/views/image_detector/side_nav_options.dart';
import 'package:lingua_ml/views/landing_children/language_selection.dart';
import 'package:lingua_ml/views/translation/translator.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LnadingPageState createState() => _LnadingPageState();
}

class _LnadingPageState extends State<LandingPage> {
  final LandingPageHelper _helper = LandingPageHelper.instance;
  final SpeechTT _speechHelper = SpeechTT.instance;
  bool _isSpeaking = false;
  // Future<void> speak() async {
  //   await _helper.flutterTts.setLanguage(languageCode);
  //   await _helper.flutterTts.speak(text);
  // }

  bool _speechEnabled = false;
  Future<void> initSpeechState() async {
    try {
      var hasSpeech = await _speechHelper.speechToText.initialize(
        onError: (err) {
          _speechHelper.errorListener(err, message: (message) {});
        },
        onStatus: (stat) {
          _speechHelper.statusListener(stat, result: (status) {});
        },
        debugLogging: true,
      );
      if (hasSpeech) {
        var systemLocale = await _speechHelper.speechToText.systemLocale();
      }
      if (!mounted) return;

      setState(() {
        _speechEnabled = hasSpeech;
      });
    } catch (e) {
      setState(() {
        Fluttertoast.showToast(
            msg: "Speech recognition failed: ${e.toString()}");
        _speechEnabled = false;
      });
    }
  }

  void _stopListening() async {
    await _speechHelper.speechToText.stop();
    // setState(() {});
  }

  Future _speak() async {
    setState(() {
      _isSpeaking = true;
    });
    await _helper.flutterTts
        .setLanguage(_helper.chosenLanguageTranslateTo.code);
    await _helper.flutterTts
        .speak(_helper.translatedController.text)
        .whenComplete(() => setState(() => _isSpeaking = false));
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

  Future<void> anotherTranslator(
    String text, {
    required LanguageModel from,
    required LanguageModel to,
    required ValueChanged<String> callback,
  }) async {
    setState(() {
      isTranslating = true;
    });
    bool isDownloadedTo =
        await _helper.languageModelService.returnableChecker(to.code);
    bool isDownloadedFrom =
        await _helper.languageModelService.returnableChecker(from.code);
    if (isDownloadedFrom && isDownloadedTo) {
      /// Translate
      callback(await _helper.manualTranslate(text, from: from, to: to));
    } else {
      if (!isDownloadedFrom) {
        setState(() {
          isDownloadingModel = true;
        });
        await _helper.languageModelService.downloadModel(from.code);
      }
      if (!isDownloadedTo) {
        setState(() {
          isDownloadingModel = true;
        });
        await _helper.languageModelService.downloadModel(to.code);
      }
      setState(() {
        isDownloadingModel = false;
      });
      await Future.delayed(const Duration(milliseconds: 100));
      callback(
        await _helper.manualTranslate(text, from: from, to: to).whenComplete(
              () => setState(() {
                isTranslating = true;
              }),
            ),
      );
    }
  }

  void clearData() {
    setState(() {
      imageFile = null;
      _helper.controller.clear();
      _helper.translatedController.clear();
    });
  }

  void init() async {
    if (Platform.isIOS) {
      await _helper.flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.voicePrompt);
    }
    await initSpeechState();
  }

  _startListening() async {
    await _speechHelper.speechToText.listen(
      onResult: (res) {
        _speechHelper.resultListener(
          res,
          finalResult: (finalResult) async {
            await anotherTranslator(
              finalResult,
              from: _helper.chosenLanguageTranslateFrom,
              to: _helper.chosenLanguageTranslateTo,
              callback: (String val) {
                setState(() {
                  _helper.translatedController.text = val;
                });
              },
            );
          },
          listenedWords: (listenedWords) {
            print(listenedWords);
            setState(() {
              _helper.controller.text = listenedWords;
            });
          },
        );
      },
      localeId: _helper.chosenLanguageTranslateFrom.code.replaceAll('-', '_'),
    );
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  void initState() {
    print("INIT");
    _helper.debouncer.obj.listen((String text) async {
      await ttranslate();
    });
    init();
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                onPressed: () {
                  clearData();
                },
                backgroundColor: Colors.red,
                child: const Tooltip(
                  message: "Clear data",
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_speechEnabled) ...{
                FloatingActionButton(
                  onPressed: () {
                    if (_speechHelper.speechToText.isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                    setState(() {});
                  },
                  backgroundColor: Colors.grey.shade100,
                  child: Center(
                    child: Icon(
                      _speechHelper.speechToText.isListening
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
              },
              FloatingActionButton(
                onPressed: _helper.translatedController.text.isNotEmpty
                    ? () async {
                        if (!_isSpeaking) {
                          await _speak();
                        } else {
                          _helper.flutterTts.stop();
                        }
                      }
                    : null,
                backgroundColor: Colors.grey.shade100,
                child: Center(
                  child: Icon(
                    _isSpeaking ? Icons.volume_mute : Icons.volume_up,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _helper.scrollController,
                    child: ListView(
                      controller: _helper.scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      children: [
                        LanguageSelectionPage(
                          hasChanged: (bool b) async {
                            if (_helper.controller.text.isNotEmpty) {
                              await ttranslate();
                            }
                          },
                          onChangeFrom: (LanguageModel f) async {
                            await anotherTranslator(
                              _helper.controller.text,
                              callback: (String value) {
                                setState(() {
                                  _helper.controller.text = value;
                                });
                              },
                              from: f,
                              to: _helper.chosenLanguageTranslateFrom,
                            );
                          },
                          onChangeTo: (LanguageModel f) async {
                            await anotherTranslator(
                              _helper.controller.text,
                              callback: (String value) {
                                setState(() {
                                  _helper.translatedController.text = value;
                                });
                              },
                              from: _helper.chosenLanguageTranslateFrom,
                              to: _helper.chosenLanguageTranslateTo,
                            );
                          },
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
                                _helper.controller.text = _helper
                                    .translationService
                                    .populateFirst(texts.blocks);
                              });
                              await ttranslate();
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
                        ),
                        const SafeArea(
                          child: SizedBox(
                            height: 90,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // if (imageFile != null || controller.text.isNotEmpty) ...{
            // Positioned(
            //   right: 10,
            //   bottom: 10,
            //   child: SideNavOptions(
            //     onClear: () {
            //       clearData();
            //     },
            //     onPressedTranslate: isTranslating
            //         ? null
            //         : () async {
            //             await ttranslate();
            //           },
            //     onPressedSpeak: _helper.translatedController.text.isEmpty
            //         ? null
            //         : () async {
            // if (Platform.isIOS) {
            //   await _helper.flutterTts.setIosAudioCategory(
            //       IosTextToSpeechAudioCategory.ambient,
            //       [
            //         IosTextToSpeechAudioCategoryOptions
            //             .allowBluetooth,
            //         IosTextToSpeechAudioCategoryOptions
            //             .allowBluetoothA2DP,
            //         IosTextToSpeechAudioCategoryOptions
            //             .mixWithOthers
            //       ],
            //       IosTextToSpeechAudioMode.voicePrompt);
            // }
            //             String code = "en-US";
            //             switch (_helper.chosenLanguageTranslateTo.code) {
            //               case "es":
            //                 code = "es-ES";
            //                 break;
            //               case "zh":
            //                 code = "zh-CN";
            //                 break;
            //               case "fr":
            //                 code = "fr-FR";
            //                 break;
            //               case "hi":
            //                 code = "hi-IN";
            //                 break;
            //               case "ja":
            //                 code = "ja-JP";
            //                 break;
            //               case "ko":
            //                 code = "ko-KR";
            //                 break;
            //               default:
            //                 code = 'en-US';
            //                 break;
            //             }
            //             if (!isPlaying) {
            //               setState(() {
            //                 isPlaying = true;
            //               });
            //               await _helper.flutterTts.awaitSpeakCompletion(true);
            //               await _speak(code, _helper.translatedController.text);
            //             } else {
            //               _helper.flutterTts.stop();
            //               setState(() {
            //                 isPlaying = false;
            //               });
            //             }
            //           },
            //   ),
            // ),
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
