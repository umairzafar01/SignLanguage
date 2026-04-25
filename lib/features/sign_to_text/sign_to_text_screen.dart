import 'package:flutter/material.dart';
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
  int _modeIndex = 0;
  final _modes = ['Continuous', 'Word', 'Sentence'];
  late AnimationController _dotCtrl;
  String _result = '"I love you"';
  bool _detecting = true;

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.text2, size: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Sign to Text',
                      style: AppTextStyles.heading(size: 17)),
                  const Spacer(),
                  StatusBadge(
                    label: 'LIVE', color: AppColors.cyan, pulsing: true,
                  ),
                ],
              ),
            ),

            // Camera view
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CameraView(
                detecting: _detecting,
                dotCtrl: _dotCtrl,
              ),
            ),
            const SizedBox(height: 12),

            // Mode selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_modes.length, (i) {
                  final on = i == _modeIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modeIndex = i),
                      child: Container(
                        margin: EdgeInsets.only(right: i < _modes.length - 1 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: on ? AppColors.cyan.withOpacity(0.08) : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: on ? AppColors.cyan.withOpacity(0.3) : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(_modes[i],
                              style: AppTextStyles.caption(
                                      color: on ? AppColors.cyan : AppColors.text3)
                                  .copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // Result panel
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
                      Text(_result, style: AppTextStyles.heading(size: 19)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: AppColors.cyan.withOpacity(0.2)),
                            ),
                            child: Text('ASL · 3 signs',
                                style: AppTextStyles.label(color: AppColors.cyan)
                                    .copyWith(fontSize: 9)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _ActionBtn(
                              icon: Icons.copy_rounded, label: 'Copy',
                              onTap: () {}),
                          const SizedBox(width: 8),
                          _ActionBtn(
                              icon: Icons.volume_up_rounded, label: 'Speak',
                              onTap: () {}),
                          const SizedBox(width: 8),
                          _ActionBtn(
                              icon: Icons.star_outline_rounded, label: 'Save',
                              onTap: () {}),
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

class _CameraView extends StatelessWidget {
  final bool detecting;
  final AnimationController dotCtrl;

  const _CameraView({required this.detecting, required this.dotCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF060F14),
            const Color(0xFF040A0C),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Grid
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            // Vignette
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
            // Center hand icon with detection dots
            Center(
              child: SizedBox(
                width: 100, height: 120,
                child: Stack(
                  children: [
                    // Corner brackets
                    ..._buildCorners(),
                    // Simulated tracking dots
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sign_language_rounded,
                              color: AppColors.cyan.withOpacity(0.6), size: 52),
                        ],
                      ),
                    ),
                    // Animated dots
                    ..._buildDots(dotCtrl),
                  ],
                ),
              ),
            ),
            // Confidence badge
            Positioned(
              bottom: 12,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                            parent: dotCtrl, curve: Curves.easeInOut),
                        child: Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text('Detecting · 94%',
                          style: AppTextStyles.caption(color: AppColors.cyan)
                              .copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
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

  List<Widget> _buildCorners() {
    const color = AppColors.cyan;
    const size = 16.0;
    const t = 2.0;
    return [
      // TL
      Positioned(top: 0, left: 0,
          child: _Corner(color: color, size: size, t: t, top: true, left: true)),
      // TR
      Positioned(top: 0, right: 0,
          child: _Corner(color: color, size: size, t: t, top: true, left: false)),
      // BL
      Positioned(bottom: 0, left: 0,
          child: _Corner(color: color, size: size, t: t, top: false, left: true)),
      // BR
      Positioned(bottom: 0, right: 0,
          child: _Corner(color: color, size: size, t: t, top: false, left: false)),
    ];
  }

  List<Widget> _buildDots(AnimationController ctrl) {
    final positions = [
      const Offset(0.3, 0.2), const Offset(0.5, 0.15),
      const Offset(0.7, 0.2), const Offset(0.75, 0.4),
      const Offset(0.65, 0.6), const Offset(0.5, 0.7),
      const Offset(0.35, 0.6), const Offset(0.28, 0.4),
    ];
    return positions.map((p) => Positioned(
      left: p.dx * 100 - 3,
      top: p.dy * 120 - 3,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
        child: Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    )).toList();
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double size, t;
  final bool top, left;
  const _Corner({required this.color, required this.size,
      required this.t, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _CornerPainter(
            color: color, thickness: t, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top, left;
  const _CornerPainter({required this.color, required this.thickness,
      required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = thickness
        ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final ex = left ? size.width : 0.0;
    final ey = top ? size.height : 0.0;
    canvas.drawLine(Offset(x, y), Offset(ex, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, ey), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.cyan.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

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
              Text(label,
                  style: AppTextStyles.caption()
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
