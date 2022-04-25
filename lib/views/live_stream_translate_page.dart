import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lingua_ml/helper/landing_page_helper.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/services/speechtt_service.dart';
import 'package:lingua_ml/views/translation/translator.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class LiveStreamTranslatePage extends StatefulWidget {
  const LiveStreamTranslatePage({Key? key, required this.toTranslate})
      : super(key: key);
  final String toTranslate;
  @override
  State<LiveStreamTranslatePage> createState() =>
      _LiveStreamTranslatePageState();
}

class _LiveStreamTranslatePageState extends State<LiveStreamTranslatePage> {
  // final SpeechToText _speechHelper.speechToText = SpeechToText();
  final SpeechTT _speechHelper = SpeechTT.instance;
  List<LocaleName> _localeNames = [];
  String _currentLocaleId = 'en_US';
  final LandingPageHelper _helper = LandingPageHelper.instance;
  bool isTranslating = false;
  bool isDownloadingModel = false;
  bool _speechEnabled = false;
  String lastError = '';
  String lastStatus = '';
  String _lastWords = '';
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  change() async {
    setState(() {
      // _helper.controller.text = widget.toTranslate;s
      _currentLocaleId =
          _speechHelper.getLocale(_helper.chosenLanguageTranslateFrom.code);
    });
    // _stopListening();
    await ttranslate();
  }

  updateTextToTranslate() async {
    print("IS UPDATING");
    setState(() {
      _helper.controller.text = widget.toTranslate;
    });
    await ttranslate();
  }

  Future<void> initSpeechState() async {
    log('Initialize');
    print(_helper.chosenLanguageTranslateFrom.code);
    try {
      var hasSpeech = await _speechHelper.speechToText.initialize(
        onError: (err) {
          _speechHelper.errorListener(err, message: (message) {
            print("ERROR: $message");
          });
        },
        onStatus: (stat) {
          _speechHelper.statusListener(stat, result: (status) {
            print("Status: $status");
          });
        },
        debugLogging: true,
      );
      if (hasSpeech) {
        _localeNames = await _speechHelper.speechToText.locales();

        var systemLocale = await _speechHelper.speechToText.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _speechEnabled = hasSpeech;
        _currentLocaleId =
            _speechHelper.getLocale(_helper.chosenLanguageTranslateFrom.code);
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _speechEnabled = false;
      });
    }
  }

  Future<void> ttranslate([bool fromMic = false]) async {
    isTranslating = true;
    // _helper.controller.text = _lastWords;
    if (fromMic) {
      _helper.controller.text = _lastWords;
    }
    _helper.languageModelService.checkIsDownloaded(
        _helper.chosenLanguageTranslateTo.code, isChecking: (bool f) async {
      setState(() {
        isDownloadingModel = !f;
      });
    });

    await _helper.translateIt().then((value) {
      setState(() {
        _helper.translatedController.text = value;
      });
      return value;
    }).whenComplete(() => setState(() {
          isTranslating = false;
        }));
  }

  @override
  void initState() {
    _helper.controller.text = widget.toTranslate;
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    if (_speechHelper.speechToText.isListening) {
      _stopListening();
    }
    super.dispose();
  }

  void _stopListening() async {
    await _speechHelper.speechToText.stop();
    // setState(() {});
  }

  void _startListening() async {
    await _speechHelper.speechToText.listen(
      onResult: (res) {
        _speechHelper.resultListener(
          res,
          finalResult: (finalResult) {
            setState(() {
              _lastWords = finalResult;
              _helper.controller.text = finalResult;
            });
            ttranslate(true);
          },
          listenedWords: (listenedWords) {},
        );
      },
      localeId: _currentLocaleId,
    );
  }

  init() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await ttranslate();
    await initSpeechState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text(
              "Result View",
            ),
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  () =>
                                      _helper.chosenLanguageTranslateFrom = val,
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
                        change();
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
                                  () => _helper.chosenLanguageTranslateTo = val,
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
              TranslationPage(
                disableTextEditing: true,
                controller: _helper.controller,
                translatedController: _helper.translatedController,
                onTextChangedToTranslate: (text) {
                  _helper.debouncer.update(text);
                },
                // onPressedSpeak: () {},
              ),
            ],
          ),
          floatingActionButton: _speechEnabled
              ? FloatingActionButton(
                  onPressed: () {
                    if (_speechHelper.speechToText.isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                    setState(() {});
                  },
                  child: Center(
                    child: Icon(
                      _speechHelper.speechToText.isListening
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
        // Positioned(
        //   bottom: 10,
        //   right: 0,
        //   left: 0,
        //   child: SafeArea(
        //     child: SizedBox(
        //       width: 70,
        //       child: Center(
        //         child: MaterialButton(
        //           onPressed: () {},
        //           height: 70,
        //           padding: const EdgeInsets.all(0),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(1000),
        //           ),
        //           color: Colors.blue,
        //         ),
        //       ),
        //     ),
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
            : Container(),
      ],
    );
  }
}
