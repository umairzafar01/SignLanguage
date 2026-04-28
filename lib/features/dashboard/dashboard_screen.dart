import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../translator/translator_hub_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../speech_tools/speech_tools_screen.dart';
import '../sign_to_text/sign_to_text_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: greeting + bell ──────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGuest ? 'Browsing as' : _greeting(),
                                style: AppTextStyles.captionOf(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isGuest
                                    ? 'Guest'
                                    : _capitalize(auth.userName.isEmpty
                                        ? 'there'
                                        : auth.userName),
                                style: AppTextStyles.headingOf(context, size: 22),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isLight
                                ? LightColors.primaryLight
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: isLight ? LightColors.border : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Guest badge ────────────────────────────
                    if (isGuest)
                      _GuestBanner(
                        isLight: isLight,
                        onSignIn: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInScreen()),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // ── Hero CTA card ─────────────────────────
                    _HeroCTA(
                      isLight: isLight,
                      primary: primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TranslatorHubScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Modules ───────────────────────────────
                    Text('MODULES', style: AppTextStyles.labelOf(context)),
                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.45,
                      children: [
                        _ModuleCard(
                          title: 'Sign → Text',
                          subtitle: 'Camera detection',
                          icon: Icons.sign_language_rounded,
                          color: isLight ? LightColors.cyan : AppColors.cyan,
                          bgColor: isLight
                              ? LightColors.cyanBg
                              : AppColors.cyan.withOpacity(0.08),
                          isLight: isLight,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TranslatorHubScreen(initialMode: 0)),
                          ),
                        ),
                        _ModuleCard(
                          title: 'Text → Sign',
                          subtitle: 'Animation output',
                          icon: Icons.back_hand_rounded,
                          color: isLight ? LightColors.rose : AppColors.rose,
                          bgColor: isLight
                              ? LightColors.roseBg
                              : AppColors.rose.withOpacity(0.08),
                          isLight: isLight,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TranslatorHubScreen(initialMode: 1)),
                          ),
                        ),
                        _ModuleCard(
                          title: 'Learning',
                          subtitle: '2,400+ signs',
                          icon: Icons.menu_book_rounded,
                          color: isLight ? LightColors.violet : AppColors.violet,
                          bgColor: isLight
                              ? LightColors.violetBg
                              : AppColors.violet.withOpacity(0.08),
                          isLight: isLight,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                          ),
                        ),
                        _ModuleCard(
                          title: 'Text → Speech',
                          subtitle: 'Voice synthesis',
                          icon: Icons.volume_up_rounded,
                          color: isLight ? LightColors.amber : AppColors.amber,
                          bgColor: isLight
                            ? LightColors.amberBg
                            : AppColors.amber.withOpacity(0.08),
                          locked: isGuest,
                          isLight: isLight,
                          onTap: isGuest
                            ? () => _showGuestDialog(context)
                            : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SpeechToolsScreen()),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _capitalize(String s) => s.isEmpty
      ? s
      : s
          .split(' ')
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');

  void _showGuestDialog(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign In Required',
            style: AppTextStyles.headingOf(context, size: 18)),
        content: Text('This module is only available to registered users.',
            style: AppTextStyles.bodyOf(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: AppTextStyles.captionOf(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()));
            },
            child: Text('Sign In',
                style: AppTextStyles.caption(color: primary)
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Hero CTA ─────────────────────────────────────────────────
class _HeroCTA extends StatelessWidget {
  final bool isLight;
  final Color primary;
  final VoidCallback onTap;
  const _HeroCTA({required this.isLight, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, primary.withOpacity(0.78)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Translating',
                      style: AppTextStyles.subheading(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Sign ↔ Text in real time',
                      style: AppTextStyles.caption(color: Colors.white70)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.translate_rounded,
                  color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest Banner ─────────────────────────────────────────────
class _GuestBanner extends StatelessWidget {
  final bool isLight;
  final VoidCallback onSignIn;
  const _GuestBanner({required this.isLight, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? LightColors.primaryLight : primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline_rounded, color: primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guest Mode',
                    style: AppTextStyles.caption(color: primary)
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('2 of 4 modules available',
                    style: AppTextStyles.captionOf(context)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Sign In',
                  style: AppTextStyles.caption(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Module Card ───────────────────────────────────────────────
class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool locked;
  final bool isLight;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isLight,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isLight ? LightColors.surface : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isLight ? LightColors.border : AppColors.border),
            boxShadow: isLight
                ? const [
                    BoxShadow(
                        color: LightColors.shadow,
                        blurRadius: 14,
                        offset: Offset(0, 2))
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: color, size: 19),
                  ),
                  const Spacer(),
                  Text(title,
                      style: AppTextStyles.bodyMedium(color: color)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.captionOf(context)
                          .copyWith(fontSize: 10)),
                ],
              ),
              if (locked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.lock_rounded,
                      color: isLight ? LightColors.text3 : AppColors.text3,
                      size: 13),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
