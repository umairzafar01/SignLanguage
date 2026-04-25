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
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<AuthProvider>().signUp(
      _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim(),
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
      setState(() => _error = 'Please fill all fields correctly.');
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.text2, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create your', style: AppTextStyles.display().copyWith(fontSize: 26)),
                    Text('account', style: AppTextStyles.display().copyWith(
                      fontSize: 26, color: AppColors.cyan,
                    )),
                    const SizedBox(height: 8),
                    Text('Track progress and unlock all AI features',
                        style: AppTextStyles.body()),
                    const SizedBox(height: 20),

                    // Guest mode banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.amber.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.bolt_rounded,
                                color: AppColors.amber, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Guest Mode Available',
                                    style: AppTextStyles.caption(color: AppColors.amber)
                                        .copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('Try before registering — sign up to save progress',
                                    style: AppTextStyles.caption()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Full Name',
                      hint: 'Your full name',
                      controller: _nameCtrl,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.person_outline_rounded,
                            color: AppColors.text3, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 8),

                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.rose.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.rose.withOpacity(0.2)),
                        ),
                        child: Text(_error!,
                            style: AppTextStyles.caption(color: AppColors.rose)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Create Account', onTap: _signUp, loading: _loading),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _guest,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Skip for now — continue as ',
                                  style: AppTextStyles.caption()),
                              TextSpan(text: 'Guest',
                                  style: AppTextStyles.caption(color: AppColors.amber)
                                      .copyWith(fontWeight: FontWeight.w700)),
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
                              TextSpan(text: 'Already have an account? ',
                                  style: AppTextStyles.caption()),
                              TextSpan(text: 'Sign in',
                                  style: AppTextStyles.caption(color: AppColors.cyan)
                                      .copyWith(fontWeight: FontWeight.w700)),
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
