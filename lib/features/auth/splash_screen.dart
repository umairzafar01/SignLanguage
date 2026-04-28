import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import 'sign_in_screen.dart';
import '../dashboard/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _slideAnim = Tween(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => auth.isAuthenticated || auth.isGuest
              ? const MainScreen()
              : const SignInScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Subtle ambient gradient (top-left)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(isLight ? 0.12 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle ambient gradient (bottom-right)
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondary.withOpacity(isLight ? 0.1 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: AnimatedBuilder(
                animation: _slideAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo mark
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Container(
                            width: 126,
                            height: 126,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                          ),
                          // Middle ring
                          Container(
                            width: 98,
                            height: 98,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          // Logo container
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primary.withOpacity(0.2),
                                  primary.withOpacity(0.06),
                                ],
                              ),
                              border: Border.all(
                                color: primary.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.18),
                                  blurRadius: 32,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.sign_language_rounded,
                              color: primary,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('SignBridge',
                        style: AppTextStyles.displayOf(context)),
                    const SizedBox(height: 6),
                    Text(
                      'AI Sign Language Translator',
                      style: AppTextStyles.captionOf(context),
                    ),
                    const SizedBox(height: 52),
                    _LoadingBar(color: primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatefulWidget {
  final Color color;
  const _LoadingBar({required this.color});

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFE2E8F0)
        : AppColors.surface3;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 56,
        height: 3,
        color: trackColor,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return FractionallySizedBox(
              alignment: Alignment(_ctrl.value * 2 - 1, 0),
              widthFactor: 0.45,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
