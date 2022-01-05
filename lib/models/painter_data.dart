import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextPainterData {
  const TextPainterData(
    this.recognisedText,
    this.absoluteImageSize,
    this.rotation,
  );
  final RecognisedText recognisedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
}
