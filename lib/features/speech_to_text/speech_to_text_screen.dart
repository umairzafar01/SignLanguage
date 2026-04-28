import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/speech_to_text_service.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});
  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _listening = false;
  bool _isAvailable = false;
  bool _isInitializing = true;
  late AnimationController _waveCtrl;
  String _transcript = 'Tap the mic to start live transcription.';
  String _statusText = 'Initializing...';
  Duration _elapsed = Duration.zero;
  DateTime? _listeningStartedAt;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speechService.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _statusText = status;
          if (status == 'notListening') {
            _listening = false;
            _updateElapsed();
          }
        });
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _statusText = 'Error';
        });
        _showMessage('Speech recognition error: $message');
      },
    );

    if (!mounted) return;
    setState(() {
      _isAvailable = available;
      _isInitializing = false;
      if (!available) {
        _statusText = 'Speech service unavailable';
      } else {
        _statusText = 'Ready';
      }
    });
  }

  Future<void> _toggle() async {
    if (_isInitializing || !_isAvailable) return;

    if (_listening) {
      await _speechService.stopListening();
      _updateElapsed();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }

    _listeningStartedAt = DateTime.now();
    setState(() {
      _statusText = 'Listening...';
      _listening = true;
    });

    await _speechService.startListening(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          // Always update transcript with recognized words
          if (result.recognizedWords.isNotEmpty) {
            _transcript = result.recognizedWords;
            _statusText = 'Processing...';
          } else if (_listening) {
            _transcript = 'Listening...';
            _statusText = 'Listening...';
          }
          // When we get a final result
          if (result.finalResult) {
            _statusText = 'Completed';
            final words = result.recognizedWords
                .trim()
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .length;
            if (words > 0) {
              context
                  .read<UserProgressProvider>()
                  .recordSpeechToTextUsage(words: words);
            }
          }
        });
      },
    );
  }

  void _updateElapsed() {
    if (_listeningStartedAt == null) return;
    _elapsed = DateTime.now().difference(_listeningStartedAt!);
    _listeningStartedAt = null;
  }

  Future<void> _copyTranscript() async {
    final value = _transcript.trim();
    if (value.isEmpty || value == 'Tap the mic to start live transcription.') {
      _showMessage('No transcript to copy yet.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    _showMessage('Transcript copied.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _speechService.cancelListening();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.text2, size: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Speech to Text', style: AppTextStyles.heading(size: 17)),
                  const Spacer(),
                  StatusBadge(
                    label: _listening ? 'REC' : 'PAUSED',
                    color: AppColors.violet,
                    pulsing: _listening,
                  ),
                ],
              ),
            ),

            // Waveform
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 110,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surface,
                      AppColors.violet.withOpacity(0.06),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _isInitializing
                          ? 'Preparing mic...'
                          : (_listening ? 'Listening...' : _statusText),
                      style: AppTextStyles.label(color: AppColors.violet)
                          .copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 14),
                    _WaveformBars(ctrl: _waveCtrl, active: _listening),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Mic button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SecBtn(
                    icon: Icons.tune_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: _toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.violet,
                            const Color(0xFF6D28D9),
                          ],
                        ),
                        boxShadow: _listening
                            ? [
                                BoxShadow(
                                  color: AppColors.violet.withOpacity(0.35),
                                  blurRadius: 32, spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: AppColors.violet.withOpacity(0.1),
                                  blurRadius: 48, spreadRadius: 8,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.violet.withOpacity(0.2),
                                  blurRadius: 16,
                                ),
                              ],
                      ),
                      child: Icon(
                        _listening ? Icons.mic_rounded : Icons.mic_off_rounded,
                        color: Colors.white, size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _SecBtn(
                    icon: Icons.add_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Transcript
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSCRIPTION', style: AppTextStyles.label()),
                      const SizedBox(height: 10),
                      Text(_transcript,
                          style: AppTextStyles.body(
                              color: AppColors.text1, size: 14)
                              .copyWith(height: 1.6)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _Tag('English', AppColors.violet),
                          const SizedBox(width: 6),
                          _Tag(_formatDuration(_elapsed), AppColors.text3, border: true),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _copyTranscript,
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
                                    const Icon(Icons.copy_rounded,
                                        color: AppColors.text2, size: 13),
                                    const SizedBox(width: 5),
                                    Text('Copy',
                                        style: AppTextStyles.caption()
                                            .copyWith(fontWeight: FontWeight.w700,
                                                fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.violet.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.violet.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.sign_language_rounded,
                                        color: AppColors.violet, size: 13),
                                    const SizedBox(width: 5),
                                    Text('→ Sign',
                                        style: AppTextStyles.caption(
                                                color: AppColors.violet)
                                            .copyWith(fontWeight: FontWeight.w700,
                                                fontSize: 10)),
                                  ],
                                ),
                              ),
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

class _WaveformBars extends StatelessWidget {
  final AnimationController ctrl;
  final bool active;
  const _WaveformBars({required this.ctrl, required this.active});

  @override
  Widget build(BuildContext context) {
    final heights = [6.0, 14, 22, 32, 38, 42, 38, 32, 28, 36, 38, 28, 8];
    final delays = [0.0, .08, .16, .24, .32, .40, .32, .24, .16, .24, .32, .16, .08];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(heights.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) {
              final t = active
                  ? (ctrl.value + delays[i]) % 1.0
                  : 0.0;
              final h = active
                  ? 4 + (heights[i] - 4) * Curves.easeInOut.transform(
                        (t < 0.5 ? t * 2 : (1 - t) * 2))
                  : 4.0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3, height: h,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.violet
                      : AppColors.surface3,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class _SecBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SecBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.text2, size: 16),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final bool border;
  const _Tag(this.label, this.color, {this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: border ? Colors.transparent : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: border ? AppColors.border : color.withOpacity(0.2),
        ),
      ),
      child: Text(label,
          style: AppTextStyles.label(color: color).copyWith(fontSize: 9)),
    );
  }
}
