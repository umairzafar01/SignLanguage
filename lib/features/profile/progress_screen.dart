import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/progress_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<UserProgressProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analytics', style: AppTextStyles.caption()),
                    const SizedBox(height: 4),
                    Text('Progress', style: AppTextStyles.heading(size: 22)),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        Expanded(child: _StatCard('${progress.translations}', 'Translations', AppColors.cyan)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard('${progress.dayStreak}', 'Day Streak', AppColors.amber)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard('${progress.savedSigns}', 'Saved', AppColors.violet)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auth.isAuthenticated
                          ? 'Synced with your Firebase account'
                          : 'Guest mode: progress saved locally on this device',
                      style: AppTextStyles.caption(color: AppColors.text3),
                    ),
                    const SizedBox(height: 20),

                    // Learning progress
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.trending_up_rounded,
                                  color: AppColors.cyan, size: 16),
                              const SizedBox(width: 7),
                              Text('Learning Progress',
                                  style: AppTextStyles.subheading().copyWith(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ProgressRow(label: 'Sign to Text',
                              value: progress.moduleProgress['Sign to Text'] ?? 0.0, color: AppColors.cyan),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'Text to Sign',
                              value: progress.moduleProgress['Text to Sign'] ?? 0.0, color: AppColors.rose),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'Speech to Text',
                              value: progress.moduleProgress['Speech to Text'] ?? 0.0, color: AppColors.violet),
                          const SizedBox(height: 12),
                          ProgressRow(label: 'AI Dictionary',
                              value: progress.moduleProgress['AI Dictionary'] ?? 0.0, color: AppColors.amber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Weekly chart
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Weekly Activity',
                                  style: AppTextStyles.subheading().copyWith(fontSize: 13)),
                              Text('This Week',
                                  style: AppTextStyles.caption(color: AppColors.cyan)
                                      .copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _WeeklyChart(values: progress.weeklyActivity),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Achievements
                    Text('Achievements'.toUpperCase(),
                        style: AppTextStyles.label()),
                    const SizedBox(height: 12),
                    _AchievementRow(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.amber,
                      title: '7-Day Streak',
                      subtitle: 'Translated every day for a week',
                      earned: progress.dayStreak >= 7,
                    ),
                    const SizedBox(height: 8),
                    _AchievementRow(
                      icon: Icons.sign_language_rounded,
                      color: AppColors.cyan,
                      title: '100 Signs',
                      subtitle: 'Translated 100 signs successfully',
                      earned: progress.translations >= 100,
                    ),
                    const SizedBox(height: 8),
                    _AchievementRow(
                      icon: Icons.menu_book_rounded,
                      color: AppColors.violet,
                      title: 'Dictionary Master',
                      subtitle: 'Save 50 signs to your dictionary',
                      earned: progress.savedSigns >= 50,
                      progress: (progress.savedSigns / 50).clamp(0.0, 1.0),
                    ),
                    const SizedBox(height: 8),
                    _AchievementRow(
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.rose,
                      title: '30-Day Champion',
                      subtitle: 'Maintain a 30-day streak',
                      earned: progress.dayStreak >= 30,
                      progress: (progress.dayStreak / 30).clamp(0.0, 1.0),
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
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.display().copyWith(
                  fontSize: 22, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(),
              style: AppTextStyles.label().copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> values;
  const _WeeklyChart({required this.values});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;
    final data = values.length == 7 ? values : List<double>.filled(7, 0.0);
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_days.length, (i) {
          final isToday = i == today;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600 + i * 80),
                    curve: Curves.easeOut,
                    height: data[i] * 70,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.cyan
                          : AppColors.cyan.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isToday
                          ? [BoxShadow(
                              color: AppColors.cyan.withOpacity(0.3),
                              blurRadius: 8)]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_days[i],
                      style: AppTextStyles.label(
                              color: isToday ? AppColors.cyan : AppColors.text3)
                          .copyWith(fontSize: 8)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool earned;
  final double? progress;

  const _AchievementRow({
    required this.icon, required this.color,
    required this.title, required this.subtitle,
    required this.earned, this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned ? color.withOpacity(0.2) : AppColors.border2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: earned
                  ? color.withOpacity(0.1)
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon,
                color: earned ? color : AppColors.text3, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium(
                            color: earned ? AppColors.text1 : AppColors.text2)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption()),
                if (progress != null) ...[
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surface3,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (earned)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: color, size: 14),
            ),
        ],
      ),
    );
  }
}
