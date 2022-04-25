import 'package:flutter/material.dart';
import 'package:lingua_ml/main.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/views/detectors/vsion_detector_views/text_detector_view.dart';
import 'package:lingua_ml/views/detectors/vsion_detector_views/text_detectorv2_view.dart';
import 'package:lingua_ml/views/landing_page.dart';
import 'package:lingua_ml/views/live_stream_translate_page.dart';
import 'package:lingua_ml/views/tutorial_page.dart';
import 'package:page_transition/page_transition.dart';

class LinguaApp extends StatelessWidget {
  const LinguaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingua App - ML KIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "DEFAULT",
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          actionsIconTheme: IconThemeData(
            color: Colors.black,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case "/tutorial_page":
            return PageTransition(
              child: const TutorialPage(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
            );
          case "/text_detector_v2":
            List<LanguageModel> _args =
                settings.arguments as List<LanguageModel>;
            return PageTransition(
              child: TextDetectorV2View(
                model: _args[0],
                toModel: _args[1],
              ),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
            );
          case "/text_detector":
            return PageTransition(
              child: const TextDetectorView(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
            );
          case "/live_stream_translate_page":
            final String toTranslate = settings.arguments as String;
            return PageTransition(
              child: LiveStreamTranslatePage(
                toTranslate: toTranslate,
              ),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
            );
          default:
            return PageTransition(
              child: const LandingPage(),
              type: PageTransitionType.scale,
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
            );
        }
      },
      home: cacher.isNewUser() ? const TutorialPage() : const LandingPage(),
    );
  }
}
