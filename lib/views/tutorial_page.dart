import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingua_ml/main.dart';
import 'package:lingua_ml/models/tutorial_model.dart';
import 'package:lingua_ml/views/tutorial_viewer.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  /// Contents
  static const List<TutorialModel> _cnt = [
    TutorialModel(
      title: "Machine Learning",
      description:
          "Machine learning is the study of computer algorithms that can improve automatically through experience and by the use of data.",
      imagePath: "assets/images/mlkit.jpeg",
    ),
    TutorialModel(
      title: "Live Stream",
      description:
          "Display data on realtime feed, through live stream feature <this will depend on user's hand stability for better result>",
      imagePath: "assets/images/live.jpeg",
    ),
    TutorialModel(
      title: "Camera",
      description:
          "Display translated data from the image generated on your camera. <better result>",
      imagePath: "assets/images/camera.jpeg",
    ),
    TutorialModel(
      title: "Gallery",
      description:
          "Display translated data from your desired photo in your photo album / gallery. <better result>",
      imagePath: "assets/images/gallery.jpeg",
    ),
  ];

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  /// page controller
  /// para ma control an page view callback / result
  static final PageController _controller = PageController();
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  controller: _controller,
                  children: List.generate(
                    TutorialPage._cnt.length,
                    (index) => TutorialViewer(
                      model: TutorialPage._cnt[index],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    TutorialPage._cnt.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      margin: const EdgeInsets.only(right: 5),
                      height: 10,
                      width: _currentPage == index ? 20 : 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _currentPage == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: TextButton(
              onPressed: () {
                cacher.nowOld();
                Navigator.pushReplacementNamed(context, "/landing_page");
              },
              child: Text(
                _currentPage < TutorialPage._cnt.length - 1
                    ? "Skip"
                    : "Get Started",
              ),
            ),
          )
        ],
      ),
    );
  }
}
