import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lingua_ml/models/language_model.dart';
import 'package:lingua_ml/models/painter_data.dart';

import 'camera_view.dart';
import 'painters/text_detector_painter.dart';

class TextDetectorV2View extends StatefulWidget {
  const TextDetectorV2View(
      {Key? key,
      required this.model,
      required this.toModel,
      required this.callback})
      : super(key: key);
  final LanguageModel model;
  final LanguageModel toModel;
  final ValueChanged<String> callback;
  @override
  _TextDetectorViewV2State createState() => _TextDetectorViewV2State();
}

class _TextDetectorViewV2State extends State<TextDetectorV2View> {
  final TranslateLanguageModelManager _languageModelManager =
      GoogleMlKit.nlp.translateLanguageModelManager();
  TextDetectorV2 textDetector = GoogleMlKit.vision.textDetectorV2();

  void checkIsDownloaded() async {
    print("Checking");
    await isModelDownloaded(widget.model.code, (f) {
      setState(() => isChecking = f);
    });
    await isModelDownloaded(widget.toModel.code, (f) {
      setState(() => isChecking2 = f);
    });
  }

  Future<void> isModelDownloaded(
      String code, ValueChanged<bool> onFinish) async {
    await _languageModelManager.isModelDownloaded(code).then((value) async {
      print("DOWNLOADED: $value");
      if (value) {
        onFinish(false);
      } else {
        onFinish(true);
        await downloadModel(code).whenComplete(() => onFinish(false));
      }
    });
  }

  Future<void> downloadModel(String code) async {
    await _languageModelManager.downloadModel(code);
    return;
  }

  bool isBusy = false;
  CustomPaint? customPaint;
  bool isChecking = true;
  bool isChecking2 = true;
  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  void initState() {
    checkIsDownloaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    Theme.of(context).textTheme.apply(
          fontFamily: widget.model.fontFamily,
        );
    return isChecking2 && isChecking
        ? Scaffold(
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Please wait while we are downloading the model"),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * .35),
                    child: MaterialButton(
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey.shade300.withOpacity(.5),
                      padding: const EdgeInsets.all(0),
                      elevation: 0,
                      // style: ButtonStyle(
                      //   foregroundColor: MaterialStateProperty.resolveWith(
                      //       (states) => Colors.black54),
                      //   backgroundColor: MaterialStateProperty.resolveWith(
                      //       (st) => Colors.grey.shade300),
                      // ),
                      child: const Center(
                        child: Text("Cancel"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : CameraView(
            title: 'Live Stream',
            painterData: painterData,
            customPaint: customPaint,
            callback: widget.callback,
            onImage: (inputImage) {
              if (mounted) {
                processImage(inputImage);
              }
            },
          );
  }

  TextPainterData? painterData;
  RecognisedText? recognisedTextx;
  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    setState(() {
      isBusy = true;
    });
    final recognisedText = await textDetector.processImage(inputImage,
        script: widget.model.option);

    setState(() {
      recognisedTextx = recognisedText;
      painterData = TextPainterData(
        recognisedText,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
    });
    customPaint = CustomPaint(
      painter: TextDetectorPainter(
        recognisedText,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
        translateFrom: widget.model.translateTo,
        translateTo: widget.toModel.translateTo,
      ),
    );
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextDetectorPainter(
          recognisedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation,
          translateFrom: widget.model.translateTo,
          translateTo: widget.toModel.translateTo);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
