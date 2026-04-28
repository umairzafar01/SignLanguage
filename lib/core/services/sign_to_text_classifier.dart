import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class SignToTextPrediction {
  final String label;
  final double confidence;
  final double distance;

  const SignToTextPrediction({
    required this.label,
    required this.confidence,
    required this.distance,
  });

  static const empty = SignToTextPrediction(
    label: '',
    confidence: 0,
    distance: double.infinity,
  );
}

class _Sample {
  final String label;
  final List<double> features;

  const _Sample({required this.label, required this.features});
}

class SignToTextClassifier {
  static const String datasetAssetPath = 'assets/ASL_Mediapipe/sign_data.csv';

  final int k;
  final List<_Sample> _samples = <_Sample>[];
  bool _loaded = false;

  SignToTextClassifier({this.k = 5});

  bool get isLoaded => _loaded;
  int get sampleCount => _samples.length;

  Future<void> load() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString(datasetAssetPath);
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',');
      if (parts.length < 64) continue;

      try {
        final features = parts
            .take(63)
            .map((value) => double.parse(value.trim()))
            .toList(growable: false);
        final label = parts.sublist(63).join(',').trim();
        if (label.isEmpty) continue;
        _samples.add(_Sample(label: label, features: features));
      } catch (_) {
        continue;
      }
    }

    _loaded = _samples.isNotEmpty;
  }

  SignToTextPrediction predictFromLandmarks(List<Landmark> landmarks) {
    final features = <double>[];
    for (final landmark in landmarks) {
      features
        ..add(landmark.x)
        ..add(landmark.y)
        ..add(landmark.z);
    }
    return predict(features);
  }

  SignToTextPrediction predict(List<double> features) {
    if (!_loaded || features.length != 63 || _samples.isEmpty) {
      return SignToTextPrediction.empty;
    }

    final scored = <_ScoredSample>[];
    for (final sample in _samples) {
      scored.add(
        _ScoredSample(
          label: sample.label,
          distance: _distance(sample.features, features),
        ),
      );
    }

    scored.sort((a, b) => a.distance.compareTo(b.distance));
    final top = scored.take(math.min(k, scored.length)).toList(growable: false);

    final weights = <String, double>{};
    for (final sample in top) {
      final weight = 1.0 / (sample.distance + 0.0001);
      weights[sample.label] = (weights[sample.label] ?? 0.0) + weight;
    }

    if (weights.isEmpty) {
      return SignToTextPrediction.empty;
    }

    final bestEntry = weights.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final totalWeight = weights.values.fold<double>(0.0, (sum, value) => sum + value);
    final confidence = totalWeight <= 0 ? 0.0 : (bestEntry.value / totalWeight).clamp(0.0, 1.0);

    return SignToTextPrediction(
      label: bestEntry.key,
      confidence: confidence,
      distance: top.first.distance,
    );
  }

  static String humanizeLabel(String label) {
    final text = label.replaceAll('_', ' ').trim();
    if (text.isEmpty) return text;
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word.length == 1
            ? word.toUpperCase()
            : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  double _distance(List<double> a, List<double> b) {
    var sum = 0.0;
    for (var i = 0; i < a.length; i++) {
      final delta = a[i] - b[i];
      sum += delta * delta;
    }
    return math.sqrt(sum);
  }
}

class _ScoredSample {
  final String label;
  final double distance;

  const _ScoredSample({required this.label, required this.distance});
}