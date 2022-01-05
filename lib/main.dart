import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lingua_ml/lingua_app.dart';
import 'package:lingua_ml/services/cacher.dart';

List<CameraDescription> cameras = [];
final Cacher cacher = Cacher();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cacher.init();
  cameras = await availableCameras();
  runApp(const LinguaApp());
}
