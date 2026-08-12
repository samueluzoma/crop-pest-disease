import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'prediction_result.dart';

/// On-device inference via tflite_flutter — used on Android/iOS/desktop.
class PredictionService {
  static const int _inputSize = 224;
  static const int _numClasses = 15;
  static const double _mean = 127.5;
  static const double _std = 127.5;
  static const String _modelAsset =
      'assets/crop pest insect/model_unquant.tflite';
  static const String _labelsAsset = 'assets/crop pest insect/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset(_modelAsset);

    final labelString = await rootBundle.loadString(_labelsAsset);
    _labels = labelString
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<PredictionResult> predict(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw StateError('Failed to decode image');
    }

    final resized =
        img.copyResize(decoded, width: _inputSize, height: _inputSize);
    final input = [_imageToFloatList(resized)];
    final output = [List.filled(_numClasses, 0.0)];

    _interpreter!.run(input, output);

    // Matches the original UX pacing so the loading state doesn't flash.
    await Future.delayed(const Duration(seconds: 3));

    final scores = output[0];
    final maxConfidence = scores.reduce((a, b) => a > b ? a : b);
    final maxIndex = scores.indexOf(maxConfidence);

    return PredictionResult(
      label: _labels.isNotEmpty ? _labels[maxIndex] : 'Unknown',
      confidence: maxConfidence * 100,
    );
  }

  List<List<List<double>>> _imageToFloatList(img.Image image) {
    return List.generate(
      _inputSize,
      (y) => List.generate(_inputSize, (x) {
        final pixel = image.getPixel(x, y);
        return [
          (pixel.r.toDouble() - _mean) / _std,
          (pixel.g.toDouble() - _mean) / _std,
          (pixel.b.toDouble() - _mean) / _std,
        ];
      }),
    );
  }
}
