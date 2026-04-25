import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';

import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';

import '../sign_to_text/sign_to_text_screen.dart';
import '../text_to_sign/text_to_sign_screen.dart';
import '../speech_to_text/speech_to_text_screen.dart';
import '../text_to_speech/text_to_speech_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 HEADER TEXT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest ? 'Browsing as' : 'Good morning,',
                            style: AppTextStyles.caption(),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGuest
                                ? 'Guest'
                                : auth.userName.isEmpty
                                    ? 'Ahmad Raza'
                                    : _capitalize(auth.userName),
                            style: AppTextStyles.heading(size: 22),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Guest / streak
                      if (!isGuest)
                        _StreakBadge()
                      else
                        _GuestBanner(
                          onSignIn: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInScreen()),
                          ),
                        ),

                      const SizedBox(height: 24),

                      const SectionLabel('Modules'),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35,
                        children: [
                          _ModuleCard(
                            title: 'Sign to Text',
                            icon: Icons.sign_language_rounded,
                            color: AppColors.cyan,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignToTextScreen()),
                            ),
                          ),
                          _ModuleCard(
                            title: 'Text to Speech',
                            icon: Icons.volume_up_rounded,
                            color: AppColors.amber,
                            locked: isGuest,
                            onTap: isGuest
                                ? () => _showGuestDialog(context)
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const TextToSpeechScreen()),
                                    ),
                          ),
                          _ModuleCard(
                            title: 'Speech to Text',
                            icon: Icons.mic_rounded,
                            color: AppColors.violet,
                            locked: isGuest,
                            onTap: isGuest
                                ? () => _showGuestDialog(context)
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SpeechToTextScreen()),
                                    ),
                          ),
                          _ModuleCard(
                            title: 'Text to Sign',
                            icon: Icons.back_hand_rounded,
                            color: AppColors.rose,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TextToSignScreen()),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty
      ? s
      : s
          .split(' ')
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');

  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Sign In Required', style: AppTextStyles.heading()),
        content: Text(
          'This module is only available to registered users.',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later',
                style: AppTextStyles.body(color: AppColors.text3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
            child: Text('Sign In',
                style: AppTextStyles.bodyMedium(color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.amber.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.amber,
            size: 16,
          ),
          const SizedBox(width: 7),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '7',
                  style:
                      AppTextStyles.heading(size: 14, color: AppColors.amber),
                ),
                TextSpan(
                  text: ' day streak · ',
                  style: AppTextStyles.caption(color: AppColors.amber),
                ),
                TextSpan(
                  text: '142',
                  style: AppTextStyles.bodyMedium(color: AppColors.amber),
                ),
                TextSpan(
                  text: ' translations',
                  style: AppTextStyles.caption(color: AppColors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  final VoidCallback onSignIn;
  const _GuestBanner({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.amber,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limited Access Mode',
                  style: AppTextStyles.caption(color: AppColors.amber)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '2 of 4 modules available · Sign in to unlock all',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool locked;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTextStyles.subheading(color: color)
                        .copyWith(fontSize: 12),
                  ),
                ],
              ),
              if (locked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.lock_rounded,
                      color: AppColors.text3, size: 13),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
