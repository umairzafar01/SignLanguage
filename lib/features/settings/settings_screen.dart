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
  String _signLanguage = 'ASL (American)';
  String _confidence = 'High — above 85%';

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferencesProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final violet = isLight ? LightColors.violet : AppColors.violet;
    final amber = isLight ? LightColors.amber : AppColors.amber;
    final rose = isLight ? LightColors.rose : AppColors.rose;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  AppBackButton(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preferences', style: AppTextStyles.captionOf(context)),
                      Text('Settings', style: AppTextStyles.headingOf(context, size: 20)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _GroupLabel('Appearance', context),
                  SettingsItem(
                    icon: Icon(Icons.wb_sunny_rounded, color: amber, size: 17),
                    iconBg: amber.withOpacity(0.12),
                    label: 'Dark Mode',
                    sublabel: prefs.isDark ? 'Currently dark' : 'Currently light',
                    // ── wired to the real provider ──
                    trailing: AppToggle(
                      value: prefs.isDark,
                      onChanged: (_) => prefs.toggleTheme(),
                    ),
                  ),
                  SettingsItem(
                    icon: Icon(Icons.text_fields_rounded,
                        color: isLight ? LightColors.text2 : AppColors.text2, size: 17),
                    iconBg: isLight ? LightColors.surface2 : AppColors.surface3,
                    label: 'Text Size',
                    sublabel: 'Medium',
                    onTap: () => _showPicker(context, 'Text Size',
                        ['Small', 'Medium', 'Large', 'Extra Large'], 1),
                  ),
                  const SizedBox(height: 16),

                  _GroupLabel('Translation', context),
                  SettingsItem(
                    icon: Icon(Icons.language_rounded, color: primary, size: 17),
                    iconBg: primary.withOpacity(0.12),
                    label: 'Sign Language',
                    sublabel: _signLanguage,
                    onTap: () => _showPicker(
                      context,
                      'Sign Language',
                      ['ASL (American)', 'BSL (British)', 'PSL (Pakistani)', 'ISL (Indian)'],
                      0,
                      onSelect: (v) => setState(() => _signLanguage = v),
                    ),
                  ),
                  SettingsItem(
                    icon: Icon(Icons.my_location_rounded, color: primary, size: 17),
                    iconBg: primary.withOpacity(0.12),
                    label: 'Confidence Level',
                    sublabel: _confidence,
                    onTap: () => _showPicker(
                      context,
                      'Confidence Level',
                      [
                        'Low — above 60%',
                        'Medium — above 75%',
                        'High — above 85%',
                        'Very High — above 95%',
                      ],
                      2,
                      onSelect: (v) => setState(() => _confidence = v),
                    ),
                  ),
                  SettingsItem(
                    icon: Icon(Icons.timeline_rounded, color: violet, size: 17),
                    iconBg: violet.withOpacity(0.12),
                    label: 'Real-time Mode',
                    sublabel: 'Continuous detection',
                    trailing: AppToggle(
                        value: _realtimeMode,
                        onChanged: (v) => setState(() => _realtimeMode = v)),
                  ),
                  const SizedBox(height: 16),

                  _GroupLabel('AI Features', context),
                  SettingsItem(
                    icon: Icon(Icons.auto_awesome_rounded, color: violet, size: 17),
                    iconBg: violet.withOpacity(0.12),
                    label: 'AI Suggestions',
                    sublabel: 'Contextual recommendations',
                    trailing: AppToggle(
                        value: prefs.aiSuggestions,
                        onChanged: prefs.setAiSuggestions),
                  ),
                  SettingsItem(
                    icon: Icon(Icons.bar_chart_rounded, color: amber, size: 17),
                    iconBg: amber.withOpacity(0.12),
                    label: 'Learning Analytics',
                    trailing: AppToggle(
                        value: _analytics,
                        onChanged: (v) => setState(() => _analytics = v)),
                  ),
                  const SizedBox(height: 16),

                  _GroupLabel('Notifications', context),
                  SettingsItem(
                    icon: Icon(Icons.notifications_none_rounded, color: amber, size: 17),
                    iconBg: amber.withOpacity(0.12),
                    label: 'Push Notifications',
                    trailing: AppToggle(
                        value: prefs.notifications,
                        onChanged: prefs.setNotifications),
                  ),
                  SettingsItem(
                    icon: Icon(Icons.local_fire_department_rounded, color: amber, size: 17),
                    iconBg: amber.withOpacity(0.12),
                    label: 'Streak Reminders',
                    sublabel: 'Daily 8:00 PM',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  _GroupLabel('Data & Privacy', context),
                  SettingsItem(
                    icon: Icon(Icons.delete_outline_rounded, color: rose, size: 17),
                    iconBg: rose.withOpacity(0.1),
                    label: 'Clear History',
                    labelColor: rose,
                    trailing: Icon(Icons.chevron_right_rounded, color: rose, size: 18),
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icon(Icons.privacy_tip_outlined, color: rose, size: 17),
                    iconBg: rose.withOpacity(0.1),
                    label: 'Privacy Policy',
                    trailing: Icon(Icons.chevron_right_rounded, color: rose, size: 18),
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),

                  Center(
                    child: Column(
                      children: [
                        Text('SignBridge',
                            style: AppTextStyles.bodyMediumOf(context)
                                .copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Version 1.0.0 · Build 1',
                            style: AppTextStyles.captionOf(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _GroupLabel(String text, BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.labelOf(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 10,
          ),
        ),
      );

  void _showPicker(BuildContext context, String title, List<String> options,
      int initialIndex,
      {void Function(String)? onSelect}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight ? LightColors.surface : AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color:
                        isLight ? LightColors.surface2 : AppColors.surface3,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headingOf(context, size: 17)),
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
                        ? primary.withOpacity(0.1)
                        : (isLight ? LightColors.surface2 : AppColors.surface2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: selected
                            ? primary.withOpacity(0.3)
                            : (isLight ? LightColors.border : AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.value,
                          style: AppTextStyles.bodyMedium(
                            color: selected
                                ? primary
                                : (isLight ? LightColors.text1 : AppColors.text1),
                          ).copyWith(fontSize: 13),
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_rounded, color: primary, size: 16),
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
