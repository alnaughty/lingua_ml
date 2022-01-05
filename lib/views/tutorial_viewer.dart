import 'package:flutter/material.dart';
import 'package:lingua_ml/models/tutorial_model.dart';

class TutorialViewer extends StatelessWidget {
  TutorialViewer({Key? key, required this.model}) : super(key: key);
  final TutorialModel model;
  late List<String> _desc = model.description.replaceAll(">", "").split("<");
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            model.imagePath,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            model.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            _desc[0],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          if (_desc.length > 1) ...{
            const SizedBox(
              height: 10,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "NOTE: ",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: _desc[1],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade300,
                    ),
                  ),
                ],
              ),
            ),
            // Text(
            //   _desc[1],
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 11,
            //     color: Colors.blue.shade300,
            //   ),
            // ),
          }
        ],
      ),
    );
  }
}
