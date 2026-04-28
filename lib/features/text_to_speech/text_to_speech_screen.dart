import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/text_to_speech_service.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});
  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _playing = false;
  bool _isInitializing = true;
  double _speed = 1.0;
  String _voice = 'Natural';
  late AnimationController _pulseCtrl;
  final _voices = ['Natural', 'Clear', 'Slow'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _initTts();
  }

  Future<void> _initTts() async {
    await _ttsService.initialize();
    if (!mounted) return;
    setState(() => _isInitializing = false);
  }

  Future<void> _speakOrStop() async {
    if (_playing) {
      await _ttsService.stop();
      if (mounted) {
        setState(() => _playing = false);
      }
      return;
    }

    final input = _ctrl.text.trim();
    if (input.isEmpty || _isInitializing) return;

    await _ttsService.configureVoice(
      voicePreset: _voice,
      speed: _speed,
    );

    if (mounted) {
      setState(() => _playing = true);
    }

    await _ttsService.speak(input);
    if (!mounted) return;
    setState(() => _playing = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.text2, size: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Text to Speech', style: AppTextStyles.heading(size: 17)),
                  const Spacer(),
                  if (_playing)
                    StatusBadge(label: 'PLAYING', color: AppColors.amber, pulsing: true),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input area
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.amber.withOpacity(0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INPUT TEXT', style: AppTextStyles.label()),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _ctrl,
                            maxLines: 4,
                            maxLength: 500,
                            style: AppTextStyles.body(
                                    color: AppColors.text1, size: 14)
                                .copyWith(height: 1.6),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              counterStyle: AppTextStyles.caption(),
                              hintText: 'Enter text to speak…',
                              hintStyle: AppTextStyles.body(color: AppColors.text4),
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Voice settings
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VOICE SETTINGS', style: AppTextStyles.label()),
                          const SizedBox(height: 14),
                          Row(
                            children: _voices.map((v) {
                              final on = v == _voice;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _voice = v),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 9),
                                    decoration: BoxDecoration(
                                      color: on
                                          ? AppColors.amber.withOpacity(0.1)
                                          : AppColors.surface2,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: on
                                            ? AppColors.amber.withOpacity(0.3)
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(v,
                                          style: AppTextStyles.caption(
                                                  color: on
                                                      ? AppColors.amber
                                                      : AppColors.text3)
                                              .copyWith(fontWeight: FontWeight.w700,
                                                  fontSize: 10)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Speed: ${_speed.toStringAsFixed(1)}×',
                                  style: AppTextStyles.bodyMedium()),
                              Text('Pitch: Normal',
                                  style: AppTextStyles.caption()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppColors.amber,
                              inactiveTrackColor: AppColors.surface3,
                              thumbColor: AppColors.amber,
                              overlayColor: AppColors.amber.withOpacity(0.1),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: _speed,
                              min: 0.5, max: 2.0, divisions: 6,
                              onChanged: (v) => setState(() => _speed = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Visualizer
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) {
                        return Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(20, (i) {
                              final t = _playing
                                  ? Curves.easeInOut.transform(
                                      ((_pulseCtrl.value + i * 0.05) % 1.0))
                                  : 0.0;
                              final h = _playing
                                  ? 4 + 36 * t
                                  : 4.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: 3, height: h,
                                  decoration: BoxDecoration(
                                    color: _playing
                                        ? AppColors.amber.withOpacity(0.6 + 0.4 * t)
                                        : AppColors.surface3,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Speak button
                    GestureDetector(
                      onTap: _speakOrStop,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.amber, AppColors.amberDim],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber.withOpacity(0.25),
                              blurRadius: 20, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _playing
                                  ? Icons.stop_rounded
                                  : Icons.volume_up_rounded,
                              color: const Color(0xFF1A0C00), size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isInitializing
                                  ? 'Preparing voice engine...'
                                  : (_playing ? 'Stop' : 'Speak Text'),
                              style: AppTextStyles.subheading(
                                  color: const Color(0xFF1A0C00))
                                  .copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
