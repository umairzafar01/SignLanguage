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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => auth.isAuthenticated || auth.isGuest
              ? const MainScreen()
              : const SignInScreen(),
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Glow
          Positioned(
            bottom: -80, left: 0, right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Rings
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.12),
                            ),
                          ),
                        ),
                        Container(
                          width: 92, height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.2),
                            ),
                          ),
                        ),
                        // Logo
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.cyan.withOpacity(0.25),
                                AppColors.cyan.withOpacity(0.08),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withOpacity(0.2),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sign_language_rounded,
                            color: AppColors.cyan,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('SignBridge', style: AppTextStyles.display()),
                  const SizedBox(height: 8),
                  Text(
                    'AI Sign Language Translator',
                    style: AppTextStyles.caption(),
                  ),
                  const SizedBox(height: 48),
                  _LoadingBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatefulWidget {
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
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        width: 48, height: 2,
        color: AppColors.surface3,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return FractionallySizedBox(
              alignment: Alignment(_ctrl.value * 2 - 1, 0),
              widthFactor: 0.5,
              child: Container(color: AppColors.cyan),
            );
          },
        ),
      ),
    );
  }
}
