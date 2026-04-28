import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:csv/csv.dart';

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
  final String? source; // Track if from HF dataset

  const _Sample({
    required this.label,
    required this.features,
    this.source,
  });
}

/// Enhanced classifier that can use both local and Hugging Face dataset
class SignToTextClassifier {
  static const String localDatasetAssetPath = 'assets/ASL_Mediapipe/sign_data.csv';

  final int k;
  final List<_Sample> _samples = <_Sample>[];
  bool _loaded = false;
  int _localSamples = 0;
  int _hfSamples = 0;

  SignToTextClassifier({this.k = 5});

  bool get isLoaded => _loaded;
  int get sampleCount => _samples.length;
  int get localSampleCount => _localSamples;
  int get huggingFaceSampleCount => _hfSamples;

  /// Load local dataset
  Future<void> load() async {
    if (_loaded) return;
    await _loadLocal();
    _loaded = _samples.isNotEmpty;
  }

  /// Load local dataset only
  Future<void> _loadLocal() async {
    try {
      final raw = await rootBundle.loadString(localDatasetAssetPath);
      final lines = raw.split(RegExp(r'\r?\n'));
      
      for (final line in lines) {
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
          
          _samples.add(_Sample(
            label: label,
            features: features,
            source: 'local',
          ));
          _localSamples++;
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      print('Error loading local dataset: $e');
    }
  }

  /// Add samples from CSV string (from Hugging Face or other sources)
  /// Expected format: 63 landmark features (21 points × 3 coordinates) + label
  Future<void> addSamplesFromCSV(String csvContent) async {
    try {
      final lines = csvContent.split(RegExp(r'\r?\n'));
      
      for (final line in lines) {
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
          
          _samples.add(_Sample(
            label: label,
            features: features,
            source: 'huggingface',
          ));
          _hfSamples++;
        } catch (_) {
          continue;
        }
      }
      _loaded = _samples.isNotEmpty;
    } catch (e) {
      print('Error adding samples from CSV: $e');
    }
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
      if (sample.distance == 0) {
        return SignToTextPrediction(
          label: sample.label,
          confidence: 1.0,
          distance: 0,
        );
      }
      final weight = 1.0 / (sample.distance + 1e-6);
      weights[sample.label] = (weights[sample.label] ?? 0.0) + weight;
    }

    final maxLabel = weights.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final confidence =
        maxLabel.value / weights.values.fold<double>(0, (a, b) => a + b);
    return SignToTextPrediction(
      label: maxLabel.key,
      confidence: confidence,
      distance: scored.first.distance,
    );
  }

  double _distance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return math.sqrt(sum);
  }
}

class _ScoredSample {
  final String label;
  final double distance;

  _ScoredSample({
    required this.label,
    required this.distance,
  });
}
