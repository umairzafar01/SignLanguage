import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/services/sign_assets_mapper.dart';
import '../../core/services/speech_to_text_service.dart';

class TranslatorHubScreen extends StatefulWidget {
  final int initialMode;
  final String initialText;
  const TranslatorHubScreen({super.key, this.initialMode = 0, this.initialText = ''});
  @override
  State<TranslatorHubScreen> createState() => _TranslatorHubScreenState();
}

class _TranslatorHubScreenState extends State<TranslatorHubScreen>
    with SingleTickerProviderStateMixin {
  late int _mode;
  late AnimationController _dotCtrl;

  // Sign→Text
  final String _result = '"I love you"';
  final bool _detecting = true;
  int _modeIndex = 0;
  final _modes = ['Continuous', 'Word', 'Sentence'];

  // Text→Sign
  late final TextEditingController _textCtrl;
  final SpeechToTextService _speechSvc = SpeechToTextService();
  final List<String> _signs = [];
  final List<String> _chars = [];
  bool _listening = false;
  bool _speechReady = false;
  int _signIndex = 0;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _textCtrl = TextEditingController(text: widget.initialText.isNotEmpty ? widget.initialText : '');
    _syncSigns(_textCtrl.text);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speechSvc.initialize(
      onStatus: (s) { if (mounted && s == 'notListening') setState(() => _listening = false); },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    );
    if (mounted) setState(() => _speechReady = ok);
  }

  void _syncSigns(String text) {
    final up = text.toUpperCase();
    _signs..clear()..addAll(SignAssetsMapper.toAssets(up));
    _chars..clear()..addAll(SignAssetsMapper.supportedCharacters(up));
    if (_signIndex >= _signs.length) _signIndex = 0;
    setState(() {});
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    _textCtrl.dispose();
    _speechSvc.cancelListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cyan = isLight ? LightColors.cyan : AppColors.cyan;
    final rose = isLight ? LightColors.rose : AppColors.rose;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              AppBackButton(),
              const SizedBox(width: 12),
              Text('Translator', style: AppTextStyles.headingOf(context, size: 17)),
              const Spacer(),
              if (_mode == 0 && _detecting)
                StatusBadge(label: 'LIVE', color: cyan, pulsing: true),
            ]),
          ),
          const SizedBox(height: 14),

          // Mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isLight ? LightColors.surface2 : AppColors.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isLight ? LightColors.border : AppColors.border),
              ),
              child: Row(children: [
                _ModeTab(label: 'Sign → Text', icon: Icons.sign_language_rounded,
                    active: _mode == 0, color: cyan, isLight: isLight,
                    onTap: () => setState(() => _mode = 0)),
                _ModeTab(label: 'Text → Sign', icon: Icons.back_hand_rounded,
                    active: _mode == 1, color: rose, isLight: isLight,
                    onTap: () => setState(() => _mode = 1)),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          Expanded(child: _mode == 0
              ? _buildSignToText(context, isLight, cyan)
              : _buildTextToSign(context, isLight, rose)),
        ]),
      ),
    );
  }

  // ─── Sign → Text ────────────────────────────────────────────
  Widget _buildSignToText(BuildContext ctx, bool isLight, Color accent) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _CameraView(detecting: _detecting, dotCtrl: _dotCtrl, accent: accent, isLight: isLight),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: List.generate(_modes.length, (i) {
            final on = i == _modeIndex;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _modeIndex = i),
              child: Container(
                margin: EdgeInsets.only(right: i < _modes.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: on ? accent.withOpacity(0.12) : (isLight ? LightColors.surface : AppColors.surface),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: on ? accent.withOpacity(0.35) : (isLight ? LightColors.border : AppColors.border)),
                ),
                child: Center(child: Text(_modes[i],
                    style: AppTextStyles.caption(color: on ? accent : (isLight ? LightColors.text3 : AppColors.text3))
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 10))),
              ),
            ));
          })),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TRANSLATION RESULT', style: AppTextStyles.labelOf(ctx)),
                const SizedBox(height: 8),
                Text(_result, style: AppTextStyles.headingOf(ctx, size: 18)),
                const SizedBox(height: 8),
                AccentChip(label: 'ASL · 3 signs', color: accent, selected: true),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(children: [
            Expanded(child: _ActionBtn(icon: Icons.copy_rounded, label: 'Copy', accent: accent, isLight: isLight,
                onTap: () => Clipboard.setData(ClipboardData(text: _result)))),
            const SizedBox(width: 8),
            Expanded(child: _ActionBtn(icon: Icons.volume_up_rounded, label: 'Speak', accent: accent, isLight: isLight, onTap: () {})),
            const SizedBox(width: 8),
            Expanded(child: _ActionBtn(icon: Icons.star_outline_rounded, label: 'Save', accent: accent, isLight: isLight, onTap: () {})),
          ]),
        ),
      ],
    );
  }


  // ─── Text → Sign (all signs as word grid) ───────────────────
  Widget _buildTextToSign(BuildContext ctx, bool isLight, Color accent) {
    final hasSigns = _chars.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isLight ? LightColors.surface : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withOpacity(0.25)),
                boxShadow: isLight ? const [BoxShadow(color: LightColors.shadow, blurRadius: 12, offset: Offset(0, 2))] : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textCtrl,
                    maxLength: 200,
                    maxLines: 2,
                    style: AppTextStyles.body(color: isLight ? LightColors.text1 : AppColors.text1, size: 15).copyWith(height: 1.5),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      hintText: 'Type text to translate to sign…',
                      hintStyle: AppTextStyles.body(color: isLight ? LightColors.text4 : AppColors.text4),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: _syncSigns,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_textCtrl.text.length}/200', style: AppTextStyles.captionOf(ctx)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Clipboard.setData(ClipboardData(text: _textCtrl.text)),
                            child: Icon(Icons.copy_rounded, color: isLight ? LightColors.text3 : AppColors.text3, size: 18),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () async {
                              if (!_speechReady) return;
                              if (_listening) {
                                await _speechSvc.stopListening();
                                setState(() => _listening = false);
                                return;
                              }
                              await _speechSvc.startListening(onResult: (r) {
                                if (!mounted) return;
                                setState(() {
                                  _listening = !r.finalResult;
                                  _textCtrl.text = r.recognizedWords;
                                });
                                _syncSigns(r.recognizedWords);
                              });
                              if (mounted) setState(() => _listening = true);
                            },
                            child: Icon(
                              _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                              color: _listening ? accent : (isLight ? LightColors.text3 : AppColors.text3),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              height: 420,
              decoration: BoxDecoration(
                color: isLight ? LightColors.surface : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isLight ? LightColors.border : AppColors.border),
                boxShadow: isLight ? const [BoxShadow(color: LightColors.shadow, blurRadius: 12, offset: Offset(0, 2))] : [],
              ),
              child: hasSigns
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: List.generate(_chars.length, (i) {
                            final char = _chars[i];
                            final asset = i < _signs.length ? _signs[i] : null;
                            final active = i == _signIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _signIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 82,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: active ? accent.withOpacity(0.12) : (isLight ? LightColors.surface2 : AppColors.surface2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: active ? accent.withOpacity(0.5) : (isLight ? LightColors.border : AppColors.border),
                                    width: active ? 1.5 : 1,
                                  ),
                                  boxShadow: active
                                      ? [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 4))]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
                                        child: asset != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.asset(
                                                  asset,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => Center(
                                                    child: Text(
                                                      char,
                                                      style: AppTextStyles.display(color: accent).copyWith(fontSize: 34, height: 1),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  char,
                                                  style: AppTextStyles.display(color: accent).copyWith(fontSize: 34, height: 1),
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        char,
                                        style: AppTextStyles.label(
                                          color: active ? accent : (isLight ? LightColors.text2 : AppColors.text2),
                                        ).copyWith(fontSize: 11, letterSpacing: 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sign_language_rounded, color: accent.withOpacity(0.3), size: 56),
                          const SizedBox(height: 12),
                          Text('Type text above to see signs', style: AppTextStyles.captionOf(ctx)),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    accent: accent,
                    isLight: isLight,
                    onTap: () => Clipboard.setData(ClipboardData(text: _textCtrl.text)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.star_outline_rounded,
                    label: 'Save',
                    accent: accent,
                    isLight: isLight,
                    onTap: () {
                      if (hasSigns) {
                        context.read<UserProgressProvider>().recordTextToSignTranslation(characters: _chars.length);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.clear_rounded,
                    label: 'Clear',
                    accent: accent,
                    isLight: isLight,
                    onTap: () {
                      _textCtrl.clear();
                      _syncSigns('');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label; final IconData icon; final bool active, isLight;
  final Color color; final VoidCallback onTap;
  const _ModeTab({required this.label, required this.icon, required this.active,
      required this.color, required this.isLight, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? (isLight ? LightColors.surface : AppColors.surface) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active && isLight
              ? const [BoxShadow(color: LightColors.shadow, blurRadius: 8, offset: Offset(0, 1))] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: active ? color : (isLight ? LightColors.text3 : AppColors.text3), size: 15),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption(
              color: active ? color : (isLight ? LightColors.text3 : AppColors.text3))
              .copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
        ]),
      ),
    ));
  }
}

class _CameraView extends StatelessWidget {
  final bool detecting; final AnimationController dotCtrl;
  final Color accent; final bool isLight;
  const _CameraView({required this.detecting, required this.dotCtrl, required this.accent, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isLight ? LightColors.border : AppColors.border),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isLight
                ? [const Color(0xFFEFF6FF), const Color(0xFFF0F9FF)]
                : [const Color(0xFF060F14), const Color(0xFF040A0C)]),
        boxShadow: isLight ? const [BoxShadow(color: LightColors.shadow, blurRadius: 16, offset: Offset(0, 4))] : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter(accent))),
          Center(child: SizedBox(width: 100, height: 120, child: Stack(children: [
            Positioned(top: 0, left: 0, child: _Corner(color: accent, size: 16, t: 2, top: true, left: true)),
            Positioned(top: 0, right: 0, child: _Corner(color: accent, size: 16, t: 2, top: true, left: false)),
            Positioned(bottom: 0, left: 0, child: _Corner(color: accent, size: 16, t: 2, top: false, left: true)),
            Positioned(bottom: 0, right: 0, child: _Corner(color: accent, size: 16, t: 2, top: false, left: false)),
            Center(child: Icon(Icons.sign_language_rounded, color: accent.withOpacity(0.55), size: 52)),
          ]))),
          Positioned(bottom: 12, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isLight ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                FadeTransition(opacity: CurvedAnimation(parent: dotCtrl, curve: Curves.easeInOut),
                    child: Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle))),
                const SizedBox(width: 7),
                Text('Detecting · 94%',
                    style: AppTextStyles.caption(color: accent).copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
              ]),
            )),
          ),
        ]),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color; final double size, t; final bool top, left;
  const _Corner({required this.color, required this.size, required this.t, required this.top, required this.left});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size,
          child: CustomPaint(painter: _CornerPainter(color: color, thickness: t, top: top, left: left)));
}

class _CornerPainter extends CustomPainter {
  final Color color; final double thickness; final bool top, left;
  const _CornerPainter({required this.color, required this.thickness, required this.top, required this.left});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = thickness..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final x = left ? 0.0 : size.width; final y = top ? 0.0 : size.height;
    canvas.drawLine(Offset(x, y), Offset(left ? size.width : 0.0, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, top ? size.height : 0.0), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.06)..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final Color accent;
  final bool isLight; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.accent,
      required this.isLight, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isLight ? LightColors.surface2 : AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isLight ? LightColors.border : AppColors.border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: accent, size: 13),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.caption(color: accent)
              .copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
        ]),
      ),
    );
  }
}
