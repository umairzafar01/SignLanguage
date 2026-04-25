import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/services/sign_assets_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/speech_to_text_service.dart';

class TextToSignScreen extends StatefulWidget {
  final String initialText;
  const TextToSignScreen({super.key, this.initialText = 'Hello world'});
  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  final SpeechToTextService _speechService = SpeechToTextService();
  final List<String> _resolvedSigns = <String>[];
  final List<String> _resolvedChars = <String>[];
  int _langIndex = 0;
  bool _playing = false;
  bool _listening = false;
  bool _speechReady = false;
  String _speechStatus = 'Preparing mic...';
  int _signIndex = 0;
  late AnimationController _cursorCtrl;
  final _langs = ['ASL', 'BSL', 'PSL'];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
    _cursorCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _syncSignsFromText(_ctrl.text);
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final available = await _speechService.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _speechStatus = status;
          if (status == 'notListening') {
            _listening = false;
          }
        });
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _speechStatus = 'Error';
          _listening = false;
        });
        _showSnack('Speech error: $message');
      },
    );

    if (!mounted) return;
    setState(() {
      _speechReady = available;
      _speechStatus = available ? 'Mic ready' : 'Mic unavailable';
    });
  }

  void _syncSignsFromText(String value) {
    final normalized = value.toUpperCase();
    _resolvedSigns
      ..clear()
      ..addAll(SignAssetsMapper.toAssets(normalized));
    _resolvedChars
      ..clear()
      ..addAll(SignAssetsMapper.supportedCharacters(normalized));

    if (_signIndex >= _resolvedSigns.length) {
      _signIndex = 0;
      _playing = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _speechService.cancelListening();
    _ctrl.dispose();
    _cursorCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (!_speechReady) {
      _showSnack('Microphone is not ready yet.');
      return;
    }

    if (_listening) {
      await _speechService.stopListening();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }

    await _speechService.startListening(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _listening = !result.finalResult;
          _ctrl.text = result.recognizedWords;
        });
        _syncSignsFromText(result.recognizedWords);
      },
    );

    if (!mounted) return;
    setState(() => _listening = true);
  }

  void _copyText() {
    final value = _ctrl.text.trim();
    if (value.isEmpty) {
      _showSnack('Nothing to copy yet.');
      return;
    }
    Clipboard.setData(ClipboardData(text: value));
    _showSnack('Text copied.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _togglePlay() {
    if (_resolvedSigns.isEmpty) {
      _showSnack('Enter text first to show sign translation.');
      return;
    }
    setState(() => _playing = !_playing);
    if (_playing) {
      context
          .read<UserProgressProvider>()
          .recordTextToSignTranslation(characters: _resolvedChars.length);
    }
    if (_playing) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _signIndex = (_signIndex + 1) % _resolvedSigns.length;
          if (_signIndex == 0) _playing = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _resolvedSigns.length;
    final hasSigns = total > 0;
    final currentAsset = hasSigns ? _resolvedSigns[_signIndex] : null;
    final currentChar =
        hasSigns && _signIndex < _resolvedChars.length ? _resolvedChars[_signIndex] : '-';
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                        color: AppColors.surface, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.text2, size: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Text to Sign', style: AppTextStyles.heading(size: 17)),
                  const Spacer(),
                  if (_playing)
                    StatusBadge(label: 'PLAYING', color: AppColors.rose, pulsing: true),
                ],
              ),
            ),

            // Text input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.rose.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _ctrl,
                      style: AppTextStyles.body(
                              color: AppColors.text1, size: 15)
                          .copyWith(height: 1.5),
                      maxLength: 200,
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: 'Type text to translate to sign…',
                        hintStyle: AppTextStyles.body(color: AppColors.text4),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: _syncSignsFromText,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_ctrl.text.length} / 200',
                            style: AppTextStyles.caption()),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _copyText,
                              child: const Icon(Icons.copy_rounded,
                                  color: AppColors.text3, size: 18),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _toggleMic,
                              child: Icon(
                                _listening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                color:
                                    _listening ? AppColors.rose : AppColors.text3,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _speechStatus,
                      style: AppTextStyles.caption(color: AppColors.text3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Language chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ..._langs.asMap().entries.map((e) {
                    final on = e.key == _langIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _langIndex = e.key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: on
                              ? AppColors.rose.withOpacity(0.1)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: on
                                ? AppColors.rose.withOpacity(0.3)
                                : AppColors.border,
                          ),
                        ),
                        child: Text(e.value,
                            style: AppTextStyles.caption(
                                    color: on ? AppColors.rose : AppColors.text3)
                                .copyWith(fontWeight: FontWeight.w700)),
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text('Speed ×1',
                        style: AppTextStyles.caption()
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Sign animation stage
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.rose.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            key: ValueKey(_signIndex),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.rose.withOpacity(0.15),
                                      AppColors.rose.withOpacity(0.04),
                                    ],
                                  ),
                                  border: Border.all(
                                      color: AppColors.rose.withOpacity(0.25)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rose.withOpacity(0.12),
                                      blurRadius: 32,
                                    ),
                                  ],
                                ),
                                child: currentAsset == null
                                    ? const Icon(Icons.sign_language_rounded,
                                        color: AppColors.rose, size: 42)
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Image.asset(
                                          currentAsset,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              Text(currentChar,
                                  style: AppTextStyles.display().copyWith(
                                      fontSize: 24,
                                      color: AppColors.rose,
                                      letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Text(
                                hasSigns
                                    ? 'Sign ${_signIndex + 1} of $total'
                                    : 'No supported characters',
                                style: AppTextStyles.caption(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Progress segments
                      Positioned(
                        bottom: 14, left: 14, right: 14,
                        child: Row(
                          children: List.generate(total * 2 + 2, (i) {
                            final segIdx = i ~/ 2;
                            final done = segIdx < _signIndex;
                            final cur = segIdx == _signIndex;
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 3),
                                height: 2,
                                decoration: BoxDecoration(
                                  color: done
                                      ? AppColors.rose
                                      : cur
                                          ? AppColors.rose.withOpacity(0.5)
                                          : AppColors.surface3,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Playback controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PlayBtn(
                    icon: Icons.skip_previous_rounded,
                    onTap: () => setState(() {
                      if (!hasSigns) return;
                      _signIndex = (_signIndex - 1).clamp(0, _resolvedSigns.length - 1);
                    }),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.rose, const Color(0xFFBE123C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.rose.withOpacity(0.3),
                            blurRadius: 24, offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white, size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _PlayBtn(
                    icon: Icons.skip_next_rounded,
                    onTap: () => setState(() {
                      if (!hasSigns) return;
                      _signIndex = (_signIndex + 1) % _resolvedSigns.length;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PlayBtn({required this.icon, required this.onTap});

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
        child: Icon(icon, color: AppColors.text2, size: 18),
      ),
    );
  }
}
