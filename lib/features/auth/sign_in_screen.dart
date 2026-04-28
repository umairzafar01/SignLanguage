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
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await context
        .read<AuthProvider>()
        .signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => _error =
          context.read<AuthProvider>().lastError ?? 'Invalid email or password.');
    }
  }

  void _guest() {
    context.read<AuthProvider>().continueAsGuest();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Top illustration ───────────────────────────────
          _AuthHero(primary: primary, isLight: isLight),

          // ── Form ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back',
                      style: AppTextStyles.headingOf(context, size: 26)),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue your learning journey',
                    style: AppTextStyles.bodyOf(context),
                  ),
                  const SizedBox(height: 28),

                  AppTextField(
                    label: 'Email Address',
                    hint: 'you@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.mail_outline_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                          size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    controller: _passCtrl,
                    obscure: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.lock_outline_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                          size: 18),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                      ),
                      child: Text(
                        'Forgot password?',
                        style: AppTextStyles.caption(color: primary)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  // Error banner
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isLight
                                ? LightColors.roseBg
                                : AppColors.rose.withOpacity(0.08)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isLight ? LightColors.rose : AppColors.rose)
                              .withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: isLight
                                  ? LightColors.rose
                                  : AppColors.rose,
                              size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: AppTextStyles.caption(
                                    color: isLight
                                        ? LightColors.rose
                                        : AppColors.rose)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  PrimaryButton(
                      label: 'Sign In', onTap: _signIn, loading: _loading),

                  if (!auth.firebaseEnabled) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isLight
                                ? LightColors.amberBg
                                : AppColors.amber.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isLight ? LightColors.amber : AppColors.amber)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Firebase is not configured yet. Add Firebase options to enable email auth.',
                        style: AppTextStyles.caption(
                            color: isLight
                                ? LightColors.amber
                                : AppColors.amber),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Guest link
                  Center(
                    child: GestureDetector(
                      onTap: _guest,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isLight
                              ? LightColors.amberBg
                              : AppColors.amber.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isLight ? LightColors.amber : AppColors.amber)
                                .withOpacity(0.2),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Continue as ',
                                style: AppTextStyles.captionOf(context),
                              ),
                              TextSpan(
                                text: 'Guest',
                                style: AppTextStyles.caption(
                                  color: isLight
                                      ? LightColors.amber
                                      : AppColors.amber,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' — limited access',
                                style: AppTextStyles.captionOf(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen())),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: AppTextStyles.captionOf(context),
                            ),
                            TextSpan(
                              text: 'Create one',
                              style: AppTextStyles.caption(color: primary)
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

// ── Auth Hero Illustration ────────────────────────────────────
class _AuthHero extends StatelessWidget {
  final Color primary;
  final bool isLight;
  const _AuthHero({required this.primary, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final bgColor = isLight ? LightColors.primaryLight : AppColors.surface;
    return Container(
      height: 188,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: isLight ? LightColors.border : AppColors.border,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Subtle grid
          Positioned.fill(child: CustomPaint(painter: _GridPainter(primary))),
          // Glow
          Center(
            child: Container(
              width: 220,
              height: 130,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [primary.withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          // Hand cards
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _HandCard(
                    icon: Icons.waving_hand_rounded,
                    height: 70,
                    bgColor: isLight ? LightColors.surface : AppColors.surface2,
                    iconColor: isLight ? LightColors.text3 : AppColors.text3),
                const SizedBox(width: 8),
                _HandCard(
                    icon: Icons.sign_language_rounded,
                    height: 90,
                    bgColor: primary.withOpacity(0.12),
                    iconColor: primary,
                    main: true,
                    borderColor: primary.withOpacity(0.3)),
                const SizedBox(width: 8),
                _HandCard(
                    icon: Icons.back_hand_rounded,
                    height: 70,
                    bgColor: isLight ? LightColors.surface : AppColors.surface2,
                    iconColor: isLight ? LightColors.text3 : AppColors.text3),
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
  final Color bgColor;
  final Color iconColor;
  final bool main;
  final Color? borderColor;

  const _HandCard({
    required this.icon,
    required this.height,
    required this.bgColor,
    required this.iconColor,
    this.main = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: main ? 74 : 62,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: borderColor ??
              (isLight ? LightColors.border : AppColors.border),
        ),
        boxShadow: main
            ? [
                BoxShadow(
                    color: iconColor.withOpacity(0.2), blurRadius: 20)
              ]
            : [],
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: main ? 32 : 26),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.06)
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
