import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingua_ml/models/language_model.dart';

class ImagePickFromFile extends StatefulWidget {
  const ImagePickFromFile(
      {Key? key,
      required this.onPickFile,
      this.imageFile,
      required this.toTranslate,
      required this.fromTranslate,
      required this.recognisedText})
      : super(key: key);
  final File? imageFile;
  final ValueChanged<File> onPickFile;
  final ValueChanged<RecognisedText?> recognisedText;
  final LanguageModel toTranslate;
  final LanguageModel fromTranslate;
  @override
  _ImagePickFromFileState createState() => _ImagePickFromFileState();
}

class _ImagePickFromFileState extends State<ImagePickFromFile> {
  final ImagePicker _imagePicker = ImagePicker();
  var textDetector = Platform.isAndroid
      ? GoogleMlKit.vision.textDetectorV2()
      : GoogleMlKit.vision.textDetector();

  Future _processPickedFile(XFile pickedFile) async {
    widget.onPickFile(File(pickedFile.path));
    // setState(() {
    //   imageFile = File(pickedFile.path);
    // });
    final InputImage inputImage = InputImage.fromFilePath(pickedFile.path);
    _processImage(inputImage);
    // widget.onImage(inputImage);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    } else {
      Fluttertoast.showToast(msg: "No image selected");
      print('No image selected.');
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    RecognisedText recognisedText;
    if (Platform.isIOS) {
      TextDetector detector = textDetector as TextDetector;
      recognisedText = await detector.processImage(inputImage);
    } else {
      TextDetectorV2 detector = textDetector as TextDetectorV2;
      recognisedText = await detector.processImage(inputImage,
          script: widget.fromTranslate.option);
      print(recognisedText.blocks.length);
    }
    widget.recognisedText(recognisedText);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        if (widget.imageFile != null) ...{
          Image.file(widget.imageFile!),
          const SizedBox(
            height: 20,
          ),
        },
        const Text("Choose photo from :"),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: size.width,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black54,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.black45,
                      ),
                    ),
                    onPressed: () async {
                      await _getImage(ImageSource.camera);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.photo_camera_outlined,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("CAMERA")
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black54,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.black45,
                      ),
                    ),
                    onPressed: () async {
                      await _getImage(ImageSource.gallery);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.photo_album,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("GALLERY")
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
