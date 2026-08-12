import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'prediction_result.dart';

/// Web inference — no on-device TFLite support, so the image is sent to the
/// backend API (see backend/main.py) which runs the same model server-side.
class PredictionService {
  // Override at build time: flutter build web --dart-define=API_BASE_URL=https://crop-pest-disease-api.onrender.com
  static const String _apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  static String get _endpoint => '$_apiBaseUrl/predict';

  Future<void> load() async {}

  Future<PredictionResult> predict(Uint8List imageBytes) async {
    final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'leaf.jpg',
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw StateError(
          'Prediction request failed (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PredictionResult(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
