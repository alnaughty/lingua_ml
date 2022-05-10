import 'package:flutter/material.dart';
import 'package:lingua_ml/main.dart';
import 'package:lingua_ml/views/landing_page.dart';
import 'package:lingua_ml/views/tutorial_page.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (cacher.isNewUser()) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: const TutorialPage(),
          type: PageTransitionType.scale,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: const LandingPage(),
          type: PageTransitionType.scale,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
