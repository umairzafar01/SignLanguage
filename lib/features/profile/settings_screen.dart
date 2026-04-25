import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _realtimeMode = true;
  bool _analytics = false;
  String _confidence = 'High — above 85%';

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferencesProvider>();
    final themeLabel = switch (prefs.themeMode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      ThemeMode.system => 'System',
    };
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preferences', style: AppTextStyles.caption()),
                      Text('Settings', style: AppTextStyles.heading(size: 20)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Appearance
                  _GroupLabel('Appearance'),
                  SettingsItem(
                    icon: const Icon(Icons.dark_mode_rounded,
                        color: AppColors.text2, size: 16),
                    iconBg: AppColors.surface3,
                    label: 'Theme Mode',
                    sublabel: themeLabel,
                    onTap: () => _showPicker(
                      context,
                      'Theme Mode',
                      const ['Dark', 'Light', 'System'],
                      themeLabel == 'Dark' ? 0 : (themeLabel == 'Light' ? 1 : 2),
                      onSelect: (val) {
                        final mode = switch (val) {
                          'Light' => ThemeMode.light,
                          'System' => ThemeMode.system,
                          _ => ThemeMode.dark,
                        };
                        prefs.setThemeMode(mode);
                      },
                    ),
                  ),
                  SettingsItem(
                    icon: const Icon(Icons.text_fields_rounded,
                        color: AppColors.text2, size: 16),
                    iconBg: AppColors.surface3,
                    label: 'Text Size',
                    sublabel: 'Medium',
                    onTap: () => _showPicker(context, 'Text Size',
                        ['Small', 'Medium', 'Large', 'Extra Large'], 1),
                  ),
                  const SizedBox(height: 16),

                  // Translation
                  _GroupLabel('Translation'),
                  SettingsItem(
                    icon: const Icon(Icons.language_rounded,
                        color: AppColors.cyan, size: 16),
                    iconBg: AppColors.cyan.withOpacity(0.1),
                    label: 'Sign Language',
                    sublabel: prefs.signLanguage,
                    onTap: () => _showPicker(
                        context,
                        'Sign Language',
                        ['ASL (American)', 'BSL (British)', 'PSL (Pakistani)',
                          'ISL (Indian)'],
                        0,
                        onSelect: prefs.setSignLanguage),
                  ),
                  SettingsItem(
                    icon: const Icon(Icons.my_location_rounded,
                        color: AppColors.cyan, size: 16),
                    iconBg: AppColors.cyan.withOpacity(0.1),
                    label: 'Confidence Level',
                    sublabel: _confidence,
                    onTap: () => _showPicker(
                        context,
                        'Confidence Level',
                        ['Low — above 60%', 'Medium — above 75%',
                          'High — above 85%', 'Very High — above 95%'],
                        2,
                        onSelect: (val) =>
                            setState(() => _confidence = val)),
                  ),
                  SettingsItem(
                    icon: const Icon(Icons.timeline_rounded,
                        color: AppColors.violet, size: 16),
                    iconBg: AppColors.violet.withOpacity(0.1),
                    label: 'Real-time Mode',
                    sublabel: 'Continuous detection',
                    trailing: AppToggle(
                        value: _realtimeMode,
                        onChanged: (v) => setState(() => _realtimeMode = v)),
                  ),
                  const SizedBox(height: 16),

                  // AI Features
                  _GroupLabel('AI Features'),
                  SettingsItem(
                    icon: const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.violet, size: 16),
                    iconBg: AppColors.violet.withOpacity(0.1),
                    label: 'AI Suggestions',
                    sublabel: 'Contextual recommendations',
                    trailing: AppToggle(
                        value: prefs.aiSuggestions,
                        onChanged: prefs.setAiSuggestions),
                  ),
                  SettingsItem(
                    icon: const Icon(Icons.bar_chart_rounded,
                        color: AppColors.amber, size: 16),
                    iconBg: AppColors.amber.withOpacity(0.1),
                    label: 'Learning Analytics',
                    trailing: AppToggle(
                        value: _analytics,
                        onChanged: (v) => setState(() => _analytics = v)),
                  ),
                  const SizedBox(height: 16),

                  // Notifications
                  _GroupLabel('Notifications'),
                  SettingsItem(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: AppColors.amber, size: 16),
                    iconBg: AppColors.amber.withOpacity(0.1),
                    label: 'Push Notifications',
                    trailing: AppToggle(
                        value: prefs.notifications,
                        onChanged: prefs.setNotifications),
                  ),
                  SettingsItem(
                    icon: const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.amber, size: 16),
                    iconBg: AppColors.amber.withOpacity(0.1),
                    label: 'Streak Reminders',
                    sublabel: 'Daily 8:00 PM',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // Data & Privacy
                  _GroupLabel('Data & Privacy'),
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
                    icon: const Icon(Icons.privacy_tip_outlined,
                        color: AppColors.rose, size: 16),
                    iconBg: AppColors.rose.withOpacity(0.08),
                    label: 'Privacy Policy',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColors.rose, size: 18),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  // Version
                  Center(
                    child: Column(
                      children: [
                        Text('SignBridge',
                            style: AppTextStyles.bodyMedium(
                                    color: AppColors.text3)
                                .copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Version 1.0.0 · Build 1',
                            style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(
    BuildContext context,
    String title,
    List<String> options,
    int initialIndex, {
    void Function(String)? onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading(size: 17)),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((e) {
              final selected = e.key == initialIndex;
              return GestureDetector(
                onTap: () {
                  onSelect?.call(e.value);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.cyan.withOpacity(0.08)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.cyan.withOpacity(0.25)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.value,
                            style: AppTextStyles.bodyMedium(
                                    color: selected
                                        ? AppColors.cyan
                                        : AppColors.text1)
                                .copyWith(fontSize: 13)),
                      ),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.cyan, size: 16),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text.toUpperCase(), style: AppTextStyles.label()),
    );
  }
}
