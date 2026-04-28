import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_preferences_provider.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prefs = context.watch<AppPreferencesProvider>();
    final progress = context.watch<UserProgressProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final violet = isLight ? LightColors.violet : AppColors.violet;
    final amber = isLight ? LightColors.amber : AppColors.amber;
    final rose = isLight ? LightColors.rose : AppColors.rose;
    final name = auth.userName.isEmpty ? 'User' : auth.userName;
    final email = auth.userEmail.isEmpty ? 'No email set' : auth.userEmail;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero header ────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: isLight ? LightColors.surface : AppColors.surface,
                  border: Border(bottom: BorderSide(color: isLight ? LightColors.border : AppColors.border)),
                  boxShadow: isLight ? const [BoxShadow(color: LightColors.shadow, blurRadius: 12, offset: Offset(0, 2))] : [],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: () => _pickProfileImage(context),
                          child: Stack(
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                    colors: [primary.withOpacity(0.3), violet.withOpacity(0.2)],
                                  ),
                                  border: Border.all(color: primary.withOpacity(0.25)),
                                  boxShadow: [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 16)],
                                ),
                                child: auth.photoUrl.isEmpty
                                    ? Icon(Icons.person_rounded, color: primary, size: 30)
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(auth.photoUrl, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Icon(Icons.person_rounded, color: primary, size: 30)),
                                      ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: BoxDecoration(
                                    color: isLight ? LightColors.emerald : AppColors.emerald,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isLight ? LightColors.surface : AppColors.surface, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatName(name), style: AppTextStyles.headingOf(context, size: 18)),
                              const SizedBox(height: 3),
                              Text(email, style: AppTextStyles.captionOf(context)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditProfileSheet(context, auth),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isLight ? LightColors.primaryLight : AppColors.surface2,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: isLight ? LightColors.border : AppColors.border),
                            ),
                            child: Text('Edit',
                                style: AppTextStyles.caption(color: primary)
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Stat pills
                    Row(
                      children: [
                        _StatPill('${progress.translations}', 'Translated', primary, isLight),
                        const SizedBox(width: 8),
                        _StatPill('${progress.savedSigns}', 'Saved', violet, isLight),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Learning progress card
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LEARNING PROGRESS', style: AppTextStyles.labelOf(context)),
                          const SizedBox(height: 14),
                          ProgressRow(label: 'Sign to Text',
                              value: progress.moduleProgress['Sign to Text'] ?? 0.0,
                              color: isLight ? LightColors.cyan : AppColors.cyan),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'Text to Sign',
                              value: progress.moduleProgress['Text to Sign'] ?? 0.0,
                              color: rose),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'AI Dictionary',
                              value: progress.moduleProgress['AI Dictionary'] ?? 0.0,
                              color: violet),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // AI suggestions card
                    if (prefs.aiSuggestions)
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI SUGGESTIONS', style: AppTextStyles.labelOf(context)),
                            const SizedBox(height: 10),
                            ...progress.aiSuggestions().map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(Icons.auto_awesome_rounded, color: violet, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(tip, style: AppTextStyles.captionOf(context))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    Text('ACCOUNT', style: AppTextStyles.labelOf(context)),
                    const SizedBox(height: 10),
                    SettingsItem(
                      icon: Icon(Icons.person_outline_rounded, color: primary, size: 17),
                      iconBg: primary.withOpacity(0.12),
                      label: 'Personal Info',
                      sublabel: 'Name, email, photo',
                      onTap: () => _showEditProfileSheet(context, auth),
                    ),
                    SettingsItem(
                      icon: Icon(Icons.lock_outline_rounded, color: amber, size: 17),
                      iconBg: amber.withOpacity(0.12),
                      label: 'Password & Security',
                      sublabel: 'Change password',
                      onTap: () => _showSecuritySheet(context, auth),
                    ),
                    const SizedBox(height: 20),

                    Text('PREFERENCES', style: AppTextStyles.labelOf(context)),
                    const SizedBox(height: 10),
                    SettingsItem(
                      icon: Icon(Icons.tune_rounded, color: violet, size: 17),
                      iconBg: violet.withOpacity(0.12),
                      label: 'App Settings',
                      sublabel: 'Theme, language, AI',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                    SettingsItem(
                      icon: Icon(Icons.notifications_none_rounded, color: rose, size: 17),
                      iconBg: rose.withOpacity(0.12),
                      label: 'Notifications',
                      trailing: AppToggle(value: prefs.notifications, onChanged: prefs.setNotifications),
                    ),
                    const SizedBox(height: 20),

                    Text('DATA', style: AppTextStyles.labelOf(context)),
                    const SizedBox(height: 10),
                    SettingsItem(
                      icon: Icon(Icons.delete_outline_rounded, color: rose, size: 17),
                      iconBg: rose.withOpacity(0.1),
                      label: 'Clear History',
                      labelColor: rose,
                      trailing: Icon(Icons.chevron_right_rounded, color: rose, size: 18),
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: Icon(Icons.logout_rounded, color: rose, size: 17),
                      iconBg: rose.withOpacity(0.1),
                      label: 'Sign Out',
                      labelColor: rose,
                      trailing: Icon(Icons.chevron_right_rounded, color: rose, size: 18),
                      onTap: () => _confirmSignOut(context, auth),
                    ),
                    const SizedBox(height: 24),
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
      : s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    final rose = Theme.of(context).brightness == Brightness.light ? LightColors.rose : AppColors.rose;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: AppTextStyles.headingOf(context, size: 18)),
        content: Text('Are you sure you want to sign out?', style: AppTextStyles.bodyOf(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.captionOf(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()), (_) => false);
            },
            child: Text('Sign Out', style: AppTextStyles.bodyMedium(color: rose).copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null || bytes.isEmpty) return;
    final mime = (result.files.first.extension ?? 'png').toLowerCase();
    final dataUrl = 'data:image/$mime;base64,${base64Encode(bytes)}';
    final ok = await auth.updatePhotoUrl(dataUrl);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Photo updated.' : (auth.lastError ?? 'Unable to update photo.'))));
  }

  Future<void> _showEditProfileSheet(BuildContext context, AuthProvider auth) async {
    final nameCtrl = TextEditingController(text: auth.userName);
    final emailCtrl = TextEditingController(text: auth.userEmail);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: AppTextStyles.headingOf(context, size: 18)),
            const SizedBox(height: 14),
            AppTextField(label: 'Name', hint: 'Your full name', controller: nameCtrl),
            const SizedBox(height: 12),
            AppTextField(label: 'Email', hint: 'you@email.com', controller: emailCtrl,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Save Changes',
              onTap: () async {
                final ok = await auth.updateProfile(name: nameCtrl.text.trim(), email: emailCtrl.text.trim());
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Profile updated.' : (auth.lastError ?? 'Could not update.'))));
                if (ok) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSecuritySheet(BuildContext context, AuthProvider auth) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Password & Security', style: AppTextStyles.headingOf(context, size: 18)),
            const SizedBox(height: 14),
            AppTextField(label: 'Current Password', hint: 'Enter current password',
                controller: currentCtrl, obscure: true),
            const SizedBox(height: 12),
            AppTextField(label: 'New Password', hint: 'At least 8 characters',
                controller: newCtrl, obscure: true),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Change Password',
              onTap: () async {
                final ok = await auth.changePassword(
                    currentPassword: currentCtrl.text.trim(), newPassword: newCtrl.text.trim());
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Password updated.' : (auth.lastError ?? 'Failed.'))));
                if (ok) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Send Password Reset Email',
              onTap: () async {
                final ok = await auth.sendPasswordReset();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Reset email sent.' : (auth.lastError ?? 'Failed.'))));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  final bool isLight;
  const _StatPill(this.value, this.label, this.color, this.isLight);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading(size: 18, color: color).copyWith(letterSpacing: -0.5)),
            const SizedBox(height: 3),
            Text(label.toUpperCase(), style: AppTextStyles.label().copyWith(fontSize: 8),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
