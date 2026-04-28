import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:provider/provider.dart';

import '../../core/providers/progress_provider.dart';
import '../../core/services/sign_api_service.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';

/// =========================
/// SCREEN
/// =========================
class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen>
    with SingleTickerProviderStateMixin {
  static const double _baseConfidence = 0.68;
  static const int _continuousStability = 4;
  static const int _sentenceStability = 7;
  static const Duration _continuousCooldown = Duration(milliseconds: 700);
  static const Duration _sentenceCooldown = Duration(milliseconds: 1300);

  final TextToSpeechService _tts = TextToSpeechService();
  final List<String> _stableWindow = <String>[];
  final List<String> _committedWords = <String>[];

  CameraController? _cameraController;
  HandLandmarkerPlugin? _handLandmarker;

  late AnimationController _dotCtrl;

  bool _isBusy = false;
  bool _isReady = false;
  bool _cameraSupported = true;
  bool _cameraReady = false;

  String _status = 'Initializing...';
  String _currentLabel = '-';
  double _currentConfidence = 0.0;
  String _lastCommittedLabel = '';
  DateTime? _lastCommitAt;

  int _modeIndex = 0;
  final _modes = const ['Continuous', 'Word', 'Sentence'];

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _tts.initialize();

    // Camera only on native platforms (Android, iOS)
    if (kIsWeb) {
      _cameraSupported = false;
      _status = 'Web: Use API preview. Mobile: Enable camera.';
      if (mounted) {
        setState(() => _isReady = true);
      }
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      _cameraSupported = false;
      _status = 'Camera not supported on this platform.';
      if (mounted) {
        setState(() => _isReady = true);
      }
      return;
    }

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _status = 'No camera available';
        if (mounted) setState(() => _isReady = true);
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      _handLandmarker = HandLandmarkerPlugin.create(
        numHands: 1,
        minHandDetectionConfidence: 0.7,
      );

      await _cameraController!.startImageStream(_processCameraImage);

      if (!mounted) return;
      setState(() {
        _cameraReady = true;
        _isReady = true;
        _status = 'Camera ready';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraSupported = false;
        _isReady = true;
        _status = 'Camera setup failed';
      });
    }
  }

  List<double> _flattenLandmarks(List<Landmark> landmarks) {
    final features = <double>[];
    for (final landmark in landmarks) {
      features
        ..add(landmark.x)
        ..add(landmark.y)
        ..add(landmark.z);
    }
    return features;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || _handLandmarker == null) return;

    _isBusy = true;

    try {
      final hands = _handLandmarker!.detect(
        image,
        _cameraController!.description.sensorOrientation,
      );

      if (hands.isEmpty) {
        if (mounted) {
          setState(() {
            _currentLabel = '-';
            _currentConfidence = 0.0;
            _status = 'Show a hand to detect';
          });
        }
        _stableWindow.clear();
        _isBusy = false;
        return;
      }

      final features = _flattenLandmarks(hands.first.landmarks);

      if (features.length != 63) {
        _isBusy = false;
        return;
      }

      final result = await SignApiService.predict(features);

      if (result == null || !mounted) {
        _isBusy = false;
        return;
      }

      final prediction = result['prediction'] ?? '-';
      final confidence = (result['confidence'] ?? 0.0).toDouble();

      setState(() {
        _currentLabel = prediction;
        _currentConfidence = confidence;
        _status = 'Tracking...';
      });

      _updateStability(prediction, confidence);
    } catch (e) {
      print('Error: $e');
    }

    _isBusy = false;
  }

  void _updateStability(String label, double confidence) {
    if (confidence < _requiredConfidence) {
      _stableWindow.clear();
      return;
    }

    if (_stableWindow.isEmpty || _stableWindow.last == label) {
      if (_stableWindow.length < _requiredStability) {
        _stableWindow.add(label);
      }
    } else {
      _stableWindow
        ..clear()
        ..add(label);
    }

    if (_modeIndex == 1) return;

    if (_stableWindow.length >= _requiredStability) {
      _commit(label);
      _stableWindow.clear();
    }
  }

  double get _requiredConfidence {
    switch (_modeIndex) {
      case 0:
        return _baseConfidence;
      case 2:
        return 0.78;
      default:
        return 0.72;
    }
  }

  int get _requiredStability {
    switch (_modeIndex) {
      case 0:
        return _continuousStability;
      case 2:
        return _sentenceStability;
      default:
        return 999;
    }
  }

  void _commit(String label) {
    final now = DateTime.now();
    if (_lastCommittedLabel == label && _lastCommitAt != null) {
      final elapsed = now.difference(_lastCommitAt!);
      if (elapsed < _commitCooldown) return;
    }

    _committedWords.add(label);
    _lastCommittedLabel = label;
    _lastCommitAt = now;

    if (mounted) {
      setState(() {});
      context
          .read<UserProgressProvider>()
          .recordSignToTextTranslation(words: 1);
    }
  }

  Duration get _commitCooldown {
    switch (_modeIndex) {
      case 0:
        return _continuousCooldown;
      case 2:
        return _sentenceCooldown;
      default:
        return Duration.zero;
    }
  }

  String get _transcript => _committedWords.isEmpty
      ? 'Waiting for a stable sign...'
      : _committedWords.join(' ');

  Future<void> _copy() async {
    if (_transcript.isEmpty) {
      _showSnack('Nothing to copy');
      return;
    }
    await Clipboard.setData(ClipboardData(text: _transcript));
    _showSnack('Copied to clipboard');
  }

  Future<void> _speak() async {
    if (_transcript.isEmpty) {
      _showSnack('Nothing to speak');
      return;
    }
    await _tts.speak(_transcript);
  }

  void _clear() {
    setState(() {
      _committedWords.clear();
      _stableWindow.clear();
      _lastCommittedLabel = '';
      _lastCommitAt = null;
    });
    _showSnack('Transcript cleared');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    unawaited(_cameraController?.stopImageStream());
    unawaited(_cameraController?.dispose());
    _handLandmarker?.dispose();
    unawaited(_tts.dispose());
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.text2,
                        size: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Sign to Text', style: AppTextStyles.heading(size: 17)),
                  const Spacer(),
                  StatusBadge(
                    label: _cameraReady ? 'LIVE' : 'SETUP',
                    color: _cameraReady ? AppColors.cyan : AppColors.rose,
                    pulsing: _cameraReady,
                  ),
                ],
              ),
            ),

            // Camera View
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF060F14), Color(0xFF040A0C)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _cameraController != null &&
                          _cameraController!.value.isInitialized
                      ? Stack(
                          children: [
                            CameraPreview(_cameraController!),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.sign_language_rounded,
                                color: AppColors.cyan.withValues(alpha: 0.6),
                                size: 52,
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: _dotCtrl,
                                          curve: Curves.easeInOut,
                                        ),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.cyan,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        _status,
                                        style: AppTextStyles.caption(
                                          color: AppColors.cyan,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.cyan
                                    .withValues(alpha: 0.55),
                                size: 46,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _status,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption(
                                  color: AppColors.text2,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Mode Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_modes.length, (i) {
                  final selected = i == _modeIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modeIndex = i),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: i < _modes.length - 1 ? 6 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.cyan.withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.cyan.withValues(alpha: 0.3)
                                : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _modes[i],
                            style: AppTextStyles.caption(
                              color: selected ? AppColors.cyan : AppColors.text3,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Results Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSLATION RESULT',
                          style: AppTextStyles.label()),
                      const SizedBox(height: 10),
                      Text(_transcript,
                          style: AppTextStyles.heading(size: 19)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              '$_currentLabel · ${(_currentConfidence * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.label(
                                color: AppColors.cyan,
                              ).copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _copy,
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text('Copy'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _speak,
                              icon: const Icon(Icons.volume_up_rounded, size: 16),
                              label: const Text('Speak'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _clear,
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              label: const Text('Clear'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
  }
}