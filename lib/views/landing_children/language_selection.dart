import 'package:flutter/material.dart';
import 'package:lingua_ml/models/language_model.dart';

import '../../helper/landing_page_helper.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage(
      {Key? key,
      required this.hasChanged,
      required this.onChangeTo,
      required this.onChangeFrom})
      : super(key: key);
  final ValueChanged<bool> hasChanged;
  final ValueChanged<LanguageModel> onChangeFrom;
  final ValueChanged<LanguageModel> onChangeTo;
  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final LandingPageHelper _helper = LandingPageHelper.instance;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return SizedBox(
        width: constraint.maxWidth,
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
                        .where((element) => element.code != "wr")
                        .map(
                          (LanguageModel e) => DropdownMenuItem<LanguageModel>(
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
                        final LanguageModel prevLanguage =
                            _helper.chosenLanguageTranslateFrom;
                        setState(
                          () => _helper.chosenLanguageTranslateFrom = val,
                        );
                        widget.onChangeFrom(prevLanguage);
                        // widget.hasChanged(true);
                        // await ttranslate();
                        // searchOnChange.add(val);
                      }
                    },
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _helper.chosenLanguageTranslateTo.code == "wr"
                  ? null
                  : () async {
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
                      widget.hasChanged(true);
                      // await ttranslate();
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
                          (LanguageModel e) => DropdownMenuItem<LanguageModel>(
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
                        final LanguageModel prevLanguage =
                            _helper.chosenLanguageTranslateTo;
                        setState(
                          () => _helper.chosenLanguageTranslateTo = val,
                        );
                        widget.onChangeTo(prevLanguage);
                        // await ttranslate();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
