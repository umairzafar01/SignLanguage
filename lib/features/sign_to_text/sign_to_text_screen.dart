import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:provider/provider.dart';

import '../../core/providers/progress_provider.dart';
import '../../core/services/sign_to_text_classifier.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';

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

  final SignToTextClassifier _classifier = SignToTextClassifier();
  final TextToSpeechService _tts = TextToSpeechService();
  final List<String> _stableWindow = <String>[];
  final List<String> _committedWords = <String>[];

  CameraController? _cameraController;
  HandLandmarkerPlugin? _handLandmarker;
  late AnimationController _dotCtrl;
  bool _isBusy = false;
  bool _isReady = false;
  bool _modelReady = false;
  bool _cameraSupported = true;
  bool _cameraReady = false;
  String _status = 'Loading sign model...';
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

    try {
      await _classifier.load();
      _modelReady = true;
      _status = 'Model ready: ${_classifier.sampleCount} samples loaded';
    } catch (_) {
      _status = 'Failed to load dataset';
      if (mounted) {
        setState(() {});
      }
      return;
    }

    // Camera only supported on Android and iOS (not Web)
    if (kIsWeb) {
      _cameraSupported = false;
      _status = 'Camera not available on web. Use Android or iOS.';
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      _cameraSupported = false;
      _status = 'Camera not supported on this platform.';
      if (mounted) {
        setState(() {
          _isReady = true;
        });
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
        if (mounted) {
          setState(() {
            _isReady = true;
          });
        }
        return;
      }

      final camera = cameras.firstWhere(
        (device) => device.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      try {
        await _cameraController!.initialize();
      } catch (e) {
        print('Camera initialization error: $e');
        _status = 'Camera error: $e';
        if (mounted) setState(() => _isReady = true);
        return;
      }

      try {
        _handLandmarker = HandLandmarkerPlugin.create(
          numHands: 2,
          minHandDetectionConfidence: 0.7,
          delegate: HandLandmarkerDelegate.cpu,
        );
      } catch (e) {
        print('Hand landmarker initialization error: $e');
        _status = 'Hand detection unavailable: $e';
        if (mounted) setState(() => _isReady = true);
        return;
      }

      try {
        await _cameraController!.startImageStream(_processCameraImage);
      } catch (e) {
        print('Image stream error: $e');
        _status = 'Camera stream error: $e';
        if (mounted) setState(() => _isReady = true);
        return;
      }

      if (!mounted) return;
      setState(() {
        _cameraReady = true;
        _isReady = true;
        _status = 'Camera ready';
      });
    } catch (e) {
      print('Camera setup error: $e');
      if (!mounted) return;
      setState(() {
        _cameraSupported = false;
        _isReady = true;
        _status = 'Camera setup failed: $e';
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || !_modelReady || _handLandmarker == null || _cameraController == null) {
      return;
    }

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
            _status = 'Show a single hand to start detection';
          });
        }
        _stableWindow.clear();
        return;
      }

      final prediction = _classifier.predictFromLandmarks(hands.first.landmarks);
      if (!mounted || prediction.label.isEmpty) return;

      setState(() {
        _currentLabel = prediction.label;
        _currentConfidence = prediction.confidence;
        _status = 'Tracking ${hands.length} hand${hands.length == 1 ? '' : 's'}';
      });

      _updateStability(prediction);
    } catch (_) {
      if (mounted) {
        setState(() {
          _status = 'Detection error';
        });
      }
    } finally {
      _isBusy = false;
    }
  }

  void _updateStability(SignToTextPrediction prediction) {
    final requiredConfidence = _requiredConfidence;
    if (prediction.confidence < requiredConfidence) {
      _stableWindow.clear();
      return;
    }

    if (_stableWindow.isEmpty || _stableWindow.last == prediction.label) {
      if (_stableWindow.length < _requiredStability) {
        _stableWindow.add(prediction.label);
      }
    } else {
      _stableWindow
        ..clear()
        ..add(prediction.label);
    }

    if (_modeIndex == 1) {
      return;
    }

    if (_stableWindow.length >= _requiredStability) {
      _commitPrediction(prediction.label, auto: true);
      _stableWindow.clear();
    }
  }

  double get _requiredConfidence {
    switch (_modeIndex) {
      case 0:
        return _baseConfidence;
      case 2:
        return 0.78;
      case 1:
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
      case 1:
      default:
        return 999;
    }
  }

  Duration get _commitCooldown {
    switch (_modeIndex) {
      case 0:
        return _continuousCooldown;
      case 2:
        return _sentenceCooldown;
      case 1:
      default:
        return Duration.zero;
    }
  }

  String get _transcript {
    if (_committedWords.isEmpty) {
      return 'Waiting for a stable sign...';
    }
    return _committedWords.join(' ');
  }

  String get _predictionLabel {
    if (_currentLabel == '-' || _currentLabel.isEmpty) {
      return 'No prediction yet';
    }
    return SignToTextClassifier.humanizeLabel(_currentLabel);
  }

  Future<void> _commitCurrentPrediction({bool auto = false}) async {
    if (_currentLabel == '-' || _currentConfidence < _requiredConfidence) {
      if (!auto && mounted) {
        _showSnack('Hold a stable sign before saving it.');
      }
      return;
    }

    _commitPrediction(_currentLabel, auto: auto);
  }

  void _commitPrediction(String label, {required bool auto}) {
    final now = DateTime.now();
    if (_lastCommittedLabel == label && _lastCommitAt != null) {
      final elapsed = now.difference(_lastCommitAt!);
      if (elapsed < _commitCooldown) {
        return;
      }
    }

    _committedWords.add(SignToTextClassifier.humanizeLabel(label));
    _lastCommittedLabel = label;
    _lastCommitAt = now;

    if (mounted) {
      setState(() {});
      context.read<UserProgressProvider>().recordSignToTextTranslation(
            words: 1,
          );
      if (!auto) {
        _showSnack('Saved prediction to transcript.');
      }
    }
  }

  Future<void> _copyTranscript() async {
    final transcript = _committedWords.isEmpty ? _predictionLabel : _transcript;
    if (transcript.trim().isEmpty || transcript == 'Waiting for a stable sign...') {
      _showSnack('Nothing to copy yet.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: transcript));
    _showSnack('Transcript copied.');
  }

  Future<void> _speakTranscript() async {
    final transcript = _committedWords.isEmpty ? _predictionLabel : _transcript;
    if (transcript.trim().isEmpty || transcript == 'Waiting for a stable sign...') {
      _showSnack('Nothing to speak yet.');
      return;
    }
    await _tts.speak(transcript);
  }

  void _clearTranscript() {
    setState(() {
      _committedWords.clear();
      _stableWindow.clear();
      _lastCommittedLabel = '';
      _lastCommitAt = null;
    });
    _showSnack('Transcript cleared.');
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CameraView(
                controller: _cameraController,
                detecting: _cameraReady && !_isBusy,
                dotCtrl: _dotCtrl,
                status: _status,
                supported: _cameraSupported,
                ready: _isReady,
                modelReady: _modelReady,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_modes.length, (index) {
                  final selected = index == _modeIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modeIndex = index),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < _modes.length - 1 ? 6 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.cyan.withOpacity(0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.cyan.withOpacity(0.3)
                                : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _modes[index],
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSLATION RESULT', style: AppTextStyles.label()),
                      const SizedBox(height: 10),
                      Text(_transcript, style: AppTextStyles.heading(size: 19)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColors.cyan.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              '${SignToTextClassifier.humanizeLabel(_currentLabel)} · ${(_currentConfidence * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.label(
                                color: AppColors.cyan,
                              ).copyWith(fontSize: 9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'ASL Mediapipe · ${_classifier.sampleCount} samples',
                              style: AppTextStyles.label(color: AppColors.text3)
                                  .copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _ActionBtn(
                            icon: Icons.copy_rounded,
                            label: 'Copy',
                            onTap: _copyTranscript,
                          ),
                          const SizedBox(width: 8),
                          _ActionBtn(
                            icon: Icons.volume_up_rounded,
                            label: 'Speak',
                            onTap: _speakTranscript,
                          ),
                          const SizedBox(width: 8),
                          _ActionBtn(
                            icon: Icons.star_outline_rounded,
                            label: 'Save',
                            onTap: _commitCurrentPrediction,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ActionBtn(
                        icon: Icons.clear_rounded,
                        label: 'Clear',
                        onTap: _clearTranscript,
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

class _CameraView extends StatelessWidget {
  final CameraController? controller;
  final bool detecting;
  final AnimationController dotCtrl;
  final String status;
  final bool supported;
  final bool ready;
  final bool modelReady;

  const _CameraView({
    required this.controller,
    required this.detecting,
    required this.dotCtrl,
    required this.status,
    required this.supported,
    required this.ready,
    required this.modelReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Stack(
          children: [
            Positioned.fill(
              child: controller != null && controller!.value.isInitialized
                  ? CameraPreview(controller!)
                  : _CameraPlaceholder(
                      ready: ready,
                      supported: supported,
                      modelReady: modelReady,
                    ),
            ),
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 100,
                height: 120,
                child: Stack(
                  children: [
                    ..._buildCorners(),
                    Center(
                      child: Icon(
                        Icons.sign_language_rounded,
                        color: AppColors.cyan.withOpacity(0.6),
                        size: 52,
                      ),
                    ),
                    ..._buildDots(dotCtrl),
                  ],
                ),
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
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: dotCtrl,
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
                        status,
                        style: AppTextStyles.caption(color: AppColors.cyan)
                            .copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: StatusBadge(
                label: detecting ? 'DETECTING' : 'READY',
                color: detecting ? AppColors.cyan : AppColors.rose,
                pulsing: detecting,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const color = AppColors.cyan;
    const size = 16.0;
    const thickness = 2.0;
    return [
      Positioned(
        top: 0,
        left: 0,
        child: _Corner(
          color: color,
          size: size,
          thickness: thickness,
          top: true,
          left: true,
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _Corner(
          color: color,
          size: size,
          thickness: thickness,
          top: true,
          left: false,
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: _Corner(
          color: color,
          size: size,
          thickness: thickness,
          top: false,
          left: true,
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: _Corner(
          color: color,
          size: size,
          thickness: thickness,
          top: false,
          left: false,
        ),
      ),
    ];
  }

  List<Widget> _buildDots(AnimationController ctrl) {
    final positions = <Offset>[
      const Offset(0.3, 0.2),
      const Offset(0.5, 0.15),
      const Offset(0.7, 0.2),
      const Offset(0.75, 0.4),
      const Offset(0.65, 0.6),
      const Offset(0.5, 0.7),
      const Offset(0.35, 0.6),
      const Offset(0.28, 0.4),
    ];

    return positions
        .map(
          (position) => Positioned(
            left: position.dx * 100 - 3,
            top: position.dy * 120 - 3,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        )
        .toList(growable: false);
  }
}

class _CameraPlaceholder extends StatelessWidget {
  final bool ready;
  final bool supported;
  final bool modelReady;

  const _CameraPlaceholder({
    required this.ready,
    required this.supported,
    required this.modelReady,
  });

  @override
  Widget build(BuildContext context) {
    final message = !supported
        ? 'Camera not supported on this platform.'
        : !modelReady
            ? 'Loading dataset...'
            : ready
                ? 'Starting camera...'
                : 'Preparing detection...';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: AppColors.cyan.withOpacity(0.55),
            size: 46,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.text2),
          ),
          const SizedBox(height: 8),
          if (!supported)
            Text(
              'Android, iOS, or native desktop recommended',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: AppColors.text3)
                  .copyWith(fontSize: 10),
            ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double size;
  final double thickness;
  final bool top;
  final bool left;

  const _Corner({
    required this.color,
    required this.size,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          thickness: thickness,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  const _CornerPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final endX = left ? size.width : 0.0;
    final endY = top ? size.height : 0.0;
    canvas.drawLine(Offset(x, y), Offset(endX, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, endY), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.text2, size: 13),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.caption().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
