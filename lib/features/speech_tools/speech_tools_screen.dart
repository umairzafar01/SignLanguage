import 'package:flutter/material.dart';
import '../speech_to_text/speech_to_text_screen.dart';
import '../text_to_speech/text_to_speech_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';

class SpeechToolsScreen extends StatefulWidget {
  const SpeechToolsScreen({super.key});

  @override
  State<SpeechToolsScreen> createState() => _SpeechToolsScreenState();
}

class _SpeechToolsScreenState extends State<SpeechToolsScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = _index == 0 ? AppColors.amber : AppColors.violet;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Speech Tools', style: AppTextStyles.headingOf(context, size: 17)),
                        const SizedBox(height: 2),
                        Text('Text to Speech and Speech to Text', style: AppTextStyles.captionOf(context)),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: _index == 0 ? 'TTS' : 'STT',
                    color: accent,
                    pulsing: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLight ? LightColors.surface2 : AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isLight ? LightColors.border : AppColors.border),
                ),
                child: Row(
                  children: [
                    _ModeTab(
                      label: 'Text to Speech',
                      icon: Icons.volume_up_rounded,
                      active: _index == 0,
                      color: AppColors.amber,
                      isLight: isLight,
                      onTap: () => setState(() => _index = 0),
                    ),
                    _ModeTab(
                      label: 'Speech to Text',
                      icon: Icons.mic_rounded,
                      active: _index == 1,
                      color: AppColors.violet,
                      isLight: isLight,
                      onTap: () => setState(() => _index = 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _index == 0 ? 'Text to Speech' : 'Speech to Text',
                      style: AppTextStyles.heading(size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _index == 0
                          ? 'Type text and hear it spoken out loud.'
                          : 'Speak and get live transcription on screen.',
                      style: AppTextStyles.captionOf(context),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: _index == 0 ? 'Open Text to Speech' : 'Open Speech to Text',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _index == 0
                                ? const TextToSpeechScreen()
                                : const SpeechToTextScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GlassCard(
                  child: _index == 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Text to Speech', style: AppTextStyles.label()),
                            const SizedBox(height: 8),
                            Text(
                              'Use the full voice screen with speed and voice controls.',
                              style: AppTextStyles.bodyMedium(color: AppColors.text2),
                            ),
                            const SizedBox(height: 12),
                            const Icon(Icons.volume_up_rounded, color: AppColors.amber, size: 48),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Speech to Text', style: AppTextStyles.label()),
                            const SizedBox(height: 8),
                            Text(
                              'Use the live microphone transcription screen.',
                              style: AppTextStyles.bodyMedium(color: AppColors.text2),
                            ),
                            const SizedBox(height: 12),
                            const Icon(Icons.mic_rounded, color: AppColors.violet, size: 48),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final bool isLight;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color.withOpacity(0.35) : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? color : (isLight ? AppColors.text3 : AppColors.text3),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(
                  color: active ? color : (isLight ? AppColors.text3 : AppColors.text3),
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
