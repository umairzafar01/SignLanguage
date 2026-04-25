import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.userName.isEmpty ? 'Ahmad Raza' : auth.userName;
    final email = auth.userEmail.isEmpty ? 'ahmad@email.com' : auth.userEmail;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Stack(
                  children: [
                    // Subtle glow
                    Positioned(
                      top: -20, right: -20,
                      child: Container(
                        width: 160, height: 120,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppColors.cyan.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.cyan.withOpacity(0.3),
                                        AppColors.violet.withOpacity(0.2),
                                      ],
                                    ),
                                    border: Border.all(
                                        color: AppColors.cyan.withOpacity(0.3)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.cyan.withOpacity(0.15),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.person_rounded,
                                      color: AppColors.text1, size: 28),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    width: 14, height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.surface, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatName(name),
                                      style: AppTextStyles.heading(size: 18)),
                                  const SizedBox(height: 3),
                                  Text(email, style: AppTextStyles.caption()),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.surface2,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text('Edit',
                                    style: AppTextStyles.caption()
                                        .copyWith(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _StatPill('142', 'Translated', AppColors.cyan),
                            const SizedBox(width: 8),
                            _StatPill('7', 'Day Streak', AppColors.amber),
                            const SizedBox(width: 8),
                            _StatPill('38', 'Saved Signs', AppColors.violet),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LEARNING PROGRESS', style: AppTextStyles.label()),
                          const SizedBox(height: 14),
                          ProgressRow(label: 'Sign to Text',
                              value: 0.78, color: AppColors.cyan),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'Text to Sign',
                              value: 0.45, color: AppColors.rose),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'AI Dictionary',
                              value: 0.62, color: AppColors.violet),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Account settings
                    Text('ACCOUNT', style: AppTextStyles.label()),
                    const SizedBox(height: 10),
                    SettingsItem(
                      icon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.cyan, size: 16),
                      iconBg: AppColors.cyan.withOpacity(0.1),
                      label: 'Personal Info',
                      sublabel: 'Name, email, photo',
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.amber, size: 16),
                      iconBg: AppColors.amber.withOpacity(0.1),
                      label: 'Password & Security',
                      sublabel: 'Change password, 2FA',
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    Text('PREFERENCES', style: AppTextStyles.label()),
                    const SizedBox(height: 10),
                    SettingsItem(
                      icon: const Icon(Icons.tune_rounded,
                          color: AppColors.violet, size: 16),
                      iconBg: AppColors.violet.withOpacity(0.1),
                      label: 'App Settings',
                      sublabel: 'Theme, language, AI',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                    SettingsItem(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.rose, size: 16),
                      iconBg: AppColors.rose.withOpacity(0.1),
                      label: 'Notifications',
                      trailing: AppToggle(value: true, onChanged: (_) {}),
                    ),
                    const SizedBox(height: 20),

                    Text('DATA', style: AppTextStyles.label()),
                    const SizedBox(height: 10),
                    SettingsItem(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.rose, size: 16),
                      iconBg: AppColors.rose.withOpacity(0.08),
                      label: 'Clear History',
                      labelColor: AppColors.rose,
                      trailing: Icon(Icons.chevron_right_rounded,
                          color: AppColors.rose, size: 18),
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.rose, size: 16),
                      iconBg: AppColors.rose.withOpacity(0.08),
                      label: 'Sign Out',
                      labelColor: AppColors.rose,
                      trailing: Icon(Icons.chevron_right_rounded,
                          color: AppColors.rose, size: 18),
                      onTap: () => _confirmSignOut(context, auth),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatName(String s) => s.isEmpty ? s
      : s.split(' ').map((w) => w.isEmpty ? w
          : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Sign Out', style: AppTextStyles.heading()),
        content: Text('Are you sure you want to sign out?',
            style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.body(color: AppColors.text3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (_) => false,
              );
            },
            child: Text('Sign Out',
                style: AppTextStyles.bodyMedium(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.heading(size: 18, color: color)
                    .copyWith(letterSpacing: -0.5)),
            const SizedBox(height: 3),
            Text(label.toUpperCase(),
                style: AppTextStyles.label().copyWith(fontSize: 8),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
