import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingua_ml/main.dart';
import 'package:lingua_ml/models/painter_data.dart';

import 'painters/coordinate_translator.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      required this.onImage,
      this.painterData,
      this.callback,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);
  final TextPainterData? painterData;
  final String title;
  final ValueChanged<String>? callback;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20.0),
        //     child: GestureDetector(
        //       onTap: _switchScreenMode,
        //       child: Icon(
        //         _mode == ScreenMode.liveFeed
        //             ? Icons.photo_library_outlined
        //             : (Platform.isIOS
        //                 ? Icons.camera_alt_outlined
        //                 : Icons.camera),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() {
    if (_mode == ScreenMode.gallery) return null;
    if (cameras.length == 1) return null;
    return SizedBox(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 40,
          ),
          onPressed: _switchLiveCamera,
        ));
  }

  Widget _body() {
    Widget body = _liveFeedBody();
    return body;
  }

  void handleOnTap(Offset offset, Size size) {
    for (TextBlock textBlock in widget.painterData!.recognisedText.blocks) {
      final left = translateX(textBlock.rect.left, widget.painterData!.rotation,
          size, widget.painterData!.absoluteImageSize);
      final top = translateY(textBlock.rect.top, widget.painterData!.rotation,
          size, widget.painterData!.absoluteImageSize);
      final right = translateX(
          textBlock.rect.right,
          widget.painterData!.rotation,
          size,
          widget.painterData!.absoluteImageSize);
      final bottom = translateY(
          textBlock.rect.bottom,
          widget.painterData!.rotation,
          size,
          widget.painterData!.absoluteImageSize);
      Offset tr = Offset(right, top);
      Offset bl = Offset(left, bottom);
      if ((offset.dy >= tr.dy && offset.dy <= bl.dy) &&
          (offset.dx >= bl.dx && offset.dx <= tr.dx)) {
        print(textBlock.text);
        Navigator.of(context).pop();
        if (widget.callback != null) {
          widget.callback!(textBlock.text);
        }
        // Navigator.pushNamed(
        //   context,
        //   "/live_stream_translate_page",
        //   arguments: textBlock.text,
        // );
        break;
      }
    }
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller!),
          if (widget.customPaint != null)
            GestureDetector(
              onPanStart: widget.painterData == null
                  ? null
                  : (DragStartDetails details) {
                      handleOnTap(
                          details.localPosition,
                          Size(MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height - 56));
                    },
              child: widget.customPaint!,
            ),
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Slider(
              value: zoomLevel,
              min: minZoomLevel,
              max: maxZoomLevel,
              onChanged: (newSliderValue) {
                setState(() {
                  zoomLevel = newSliderValue;
                  _controller!.setZoomLevel(zoomLevel);
                });
              },
              divisions: (maxZoomLevel - 1).toInt() < 1
                  ? null
                  : (maxZoomLevel - 1).toInt(),
            ),
          ),
        ],
      ),
    );
  }

  void _switchScreenMode() async {
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      await _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      await _startLiveFeed();
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0) {
      _cameraIndex = 1;
    } else {
      _cameraIndex = 0;
    }
    await _stopLiveFeed();
    await _startLiveFeed();
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}
