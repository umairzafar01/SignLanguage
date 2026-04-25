import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../dashboard/main_screen.dart';
import 'auth_provider.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<AuthProvider>().signIn(
      _emailCtrl.text.trim(), _passCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => _error = 'Invalid email or password.');
    }
  }

  void _guest() {
    context.read<AuthProvider>().continueAsGuest();
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Top illustration
          _AuthIllustration(),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: AppTextStyles.display().copyWith(fontSize: 26)),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sign in to ',
                          style: AppTextStyles.body(),
                        ),
                        TextSpan(
                          text: 'continue learning',
                          style: AppTextStyles.body(color: AppColors.cyan),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Email Address',
                    hint: 'you@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.mail_outline_rounded,
                          color: AppColors.text3, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    controller: _passCtrl,
                    obscure: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.lock_outline_rounded,
                          color: AppColors.text3, size: 18),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot password?',
                          style: AppTextStyles.caption(color: AppColors.cyan)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.rose.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.rose.withOpacity(0.2)),
                      ),
                      child: Text(_error!, style: AppTextStyles.caption(color: AppColors.rose)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  PrimaryButton(label: 'Sign In', onTap: _signIn, loading: _loading),
                  const SizedBox(height: 16),
                  const TextDivider('or'),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Continue with Google',
                    icon: const Icon(Icons.g_mobiledata_rounded,
                        color: AppColors.text2, size: 22),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _guest,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Continue as ',
                              style: AppTextStyles.caption(),
                            ),
                            TextSpan(
                              text: 'Guest',
                              style: AppTextStyles.caption(color: AppColors.amber)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: ' — limited access',
                              style: AppTextStyles.caption(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: AppTextStyles.caption(),
                            ),
                            TextSpan(
                              text: 'Create one',
                              style: AppTextStyles.caption(color: AppColors.cyan)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Stack(
        children: [
          // Grid pattern
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Glow
          Center(
            child: Container(
              width: 200, height: 120,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Status bar area
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('9:41',
                        style: AppTextStyles.bodyMedium(color: AppColors.text1)
                            .copyWith(fontSize: 12)),
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_alt_rounded,
                            color: AppColors.text1, size: 14),
                        const SizedBox(width: 4),
                        Icon(Icons.wifi_rounded, color: AppColors.text1, size: 14),
                        const SizedBox(width: 4),
                        Icon(Icons.battery_full_rounded,
                            color: AppColors.text1, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Hand icons row
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _HandCard(icon: Icons.waving_hand_rounded,
                    height: 70, color: AppColors.surface2),
                const SizedBox(width: 6),
                _HandCard(icon: Icons.sign_language_rounded,
                    height: 88, color: AppColors.surface2,
                    accentColor: AppColors.cyan, main: true),
                const SizedBox(width: 6),
                _HandCard(icon: Icons.back_hand_rounded,
                    height: 70, color: AppColors.surface2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HandCard extends StatelessWidget {
  final IconData icon;
  final double height;
  final Color color;
  final Color? accentColor;
  final bool main;

  const _HandCard({
    required this.icon, required this.height,
    required this.color, this.accentColor, this.main = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: main ? 72 : 62,
      height: height,
      decoration: BoxDecoration(
        color: main && accentColor != null
            ? accentColor!.withOpacity(0.12)
            : color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border.all(
          color: main && accentColor != null
              ? accentColor!.withOpacity(0.3)
              : AppColors.border,
        ),
        boxShadow: main
            ? [BoxShadow(
                color: AppColors.cyan.withOpacity(0.15),
                blurRadius: 24,
              )]
            : [],
      ),
      child: Center(
        child: Icon(icon,
            color: accentColor ?? AppColors.text3,
            size: main ? 32 : 26),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
