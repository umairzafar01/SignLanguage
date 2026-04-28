import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../dashboard/main_screen.dart';
import 'auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_passCtrl.text.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await context.read<AuthProvider>().signUp(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } else {
      setState(() => _error = context.read<AuthProvider>().lastError ??
          'Please fill all fields correctly.');
    }
  }

  void _guest() {
    context.read<AuthProvider>().continueAsGuest();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconFade = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Create your\n',
                            style: AppTextStyles.headingOf(context, size: 26),
                          ),
                          TextSpan(
                            text: 'account',
                            style: AppTextStyles.heading(size: 26,
                                color: primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track progress and unlock all AI features',
                      style: AppTextStyles.bodyOf(context),
                    ),
                    const SizedBox(height: 24),

                    // Guest mode banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isLight
                            ? LightColors.amberBg
                            : AppColors.amber.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              (isLight ? LightColors.amber : AppColors.amber)
                                  .withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: (isLight ? LightColors.amber : AppColors.amber)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.bolt_rounded,
                                color: isLight
                                    ? LightColors.amber
                                    : AppColors.amber,
                                size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Guest Mode Available',
                                    style: AppTextStyles.caption(
                                            color: isLight
                                                ? LightColors.amber
                                                : AppColors.amber)
                                        .copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  'Try before registering — sign up to save progress',
                                  style: AppTextStyles.captionOf(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'Full Name',
                      hint: 'Your full name',
                      controller: _nameCtrl,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.person_outline_rounded,
                            color: iconFade, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email Address',
                      hint: 'you@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.mail_outline_rounded,
                            color: iconFade, size: 18),
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
                            color: iconFade, size: 18),
                      ),
                    ),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLight
                              ? LightColors.roseBg
                              : AppColors.rose.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (isLight ? LightColors.rose : AppColors.rose)
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
                    ],

                    const SizedBox(height: 20),
                    PrimaryButton(
                        label: 'Create Account',
                        onTap: _signUp,
                        loading: _loading),
                    const SizedBox(height: 14),

                    // Guest link
                    Center(
                      child: GestureDetector(
                        onTap: _guest,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Skip for now — continue as ',
                                  style: AppTextStyles.captionOf(context)),
                              TextSpan(
                                text: 'Guest',
                                style: AppTextStyles.caption(
                                  color: isLight
                                      ? LightColors.amber
                                      : AppColors.amber,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Already have an account? ',
                                  style: AppTextStyles.captionOf(context)),
                              TextSpan(
                                text: 'Sign in',
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
      ),
    );
  }
}
