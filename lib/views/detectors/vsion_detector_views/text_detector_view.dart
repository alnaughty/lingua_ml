import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lingua_ml/models/language_model.dart';

import 'camera_view.dart';
import 'painters/text_detector_painter.dart';

class TextDetectorView extends StatefulWidget {
  const TextDetectorView({Key? key}) : super(key: key);
  @override
  _TextDetectorViewState createState() => _TextDetectorViewState();
}

class _TextDetectorViewState extends State<TextDetectorView> {
  final TextDetector textDetector = GoogleMlKit.vision.textDetector();

  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Text Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final recognisedText = await textDetector.processImage(
      inputImage,
    );
    print('Found ${recognisedText.blocks.length} textBlocks');
    for (TextBlock x in recognisedText.blocks) {
      print(x.text);
    }
    print(recognisedText);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      // final painter = TextDetectorPainter(
      //     recognisedText,
      //     inputImage.inputImageData!.size,
      //     inputImage.inputImageData!.imageRotation);
      // customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
