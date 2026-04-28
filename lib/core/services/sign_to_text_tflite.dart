import 'dart:async';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLitePrediction {
  final String label;
  final double confidence;

  TFLitePrediction({required this.label, required this.confidence});
}

class SignToTextTFLite {
  static const String modelAsset = 'ASL_Mediapipe/sign_model.tflite';
  static const String labelsAsset = 'assets/ASL_Mediapipe/sign_labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = [];

  bool get isLoaded => _interpreter != null && _labels.isNotEmpty;

  Future<void> load() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelAsset);
      final raw = await rootBundle.loadString(labelsAsset);
      _labels = raw
          .split(RegExp(r'\r?\n'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    } catch (e) {
      rethrow;
    }
  }

  TFLitePrediction predict(List<double> inputFeatures) {
    if (!isLoaded) throw StateError('TFLite model not loaded');

    // Prepare input as [1, N]
    final input = [inputFeatures];

    // Prepare output buffer with shape [1, numLabels]
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    _interpreter!.run(input, output);

    final probs = output[0];
    var bestIndex = 0;
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > probs[bestIndex]) bestIndex = i;
    }

    final bestProb = probs[bestIndex];
    final label = bestIndex < _labels.length ? _labels[bestIndex] : 'unknown';

    return TFLitePrediction(label: label, confidence: bestProb.toDouble());
  }
}
