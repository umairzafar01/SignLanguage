import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SignPredictor {
  static const String _modelAssetPath = 'assets/sign_model.tflite';
  static const String _labelsAssetPath = 'assets/labels.json';

  Interpreter? _interpreter;
  List<String> _labels = const [];
  bool _isInitialized = false;
  String? _lastError;

  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        _modelAssetPath,
        options: options,
      );
      _labels = await _loadLabels();
      _isInitialized = true;
      _lastError = null;
    } catch (error) {
      _isInitialized = false;
      _interpreter = null;
      _labels = const [];
      _lastError = error.toString();
      rethrow;
    }
  }

  Future<List<String>> _loadLabels() async {
    final rawJson = await rootBundle.loadString(_labelsAssetPath);
    final decoded = jsonDecode(rawJson);

    if (decoded is List) {
      return decoded.map((item) => item.toString()).toList(growable: false);
    }

    if (decoded is Map<String, dynamic>) {
      final sortedKeys = decoded.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      return sortedKeys
          .map((key) => decoded[key].toString())
          .toList(growable: false);
    }

    throw const FormatException('Unsupported labels.json format.');
  }

  List<double> _normalizeLandmarks(List<double> landmarks) {
    if (landmarks.length != 63) {
      throw ArgumentError(
        'Expected 63 landmark values, got ${landmarks.length}.',
      );
    }

    final points = List<List<double>>.generate(
      21,
      (index) => landmarks.sublist(index * 3, (index * 3) + 3),
      growable: false,
    );

    final wrist = points[0];
    final centered = points
        .map(
          (point) => <double>[
            point[0] - wrist[0],
            point[1] - wrist[1],
            point[2] - wrist[2],
          ],
        )
        .toList(growable: false);

    final flattened = centered.expand((point) => point).toList(growable: false);
    final maxAbs = flattened
        .fold<double>(0.0, (max, value) => math.max(max, value.abs()));

    if (maxAbs == 0.0) {
      return flattened;
    }

    return flattened.map((value) => value / maxAbs).toList(growable: false);
  }

  Future<String> predict(List<double> landmarks) async {
    try {
      await initialize();

      final interpreter = _interpreter;
      if (interpreter == null) return 'Unknown';

      final normalized = _normalizeLandmarks(landmarks);
      final input = [normalized];

      final outputTensor = interpreter.getOutputTensor(0);
      final outputShape = outputTensor.shape;
      final classCount =
          outputShape.isNotEmpty ? outputShape.last : _labels.length;
      final output = [List<double>.filled(classCount, 0.0, growable: false)];

      interpreter.run(input, output);

      final probabilities = output.first;
      if (probabilities.isEmpty) return 'Unknown';

      var bestIndex = 0;
      var bestScore = probabilities.first;
      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > bestScore) {
          bestScore = probabilities[i];
          bestIndex = i;
        }
      }

      if (bestIndex < 0 || bestIndex >= _labels.length) return 'Unknown';
      return _labels[bestIndex];
    } catch (_) {
      return 'Unknown';
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}