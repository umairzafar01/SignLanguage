import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─── Helpers ────────────────────────────────────────────────

bool _isLight(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.light;

Color _surface(BuildContext ctx) => _isLight(ctx)
    ? LightColors.surface
    : AppColors.surface;

Color _surface2(BuildContext ctx) => _isLight(ctx)
    ? LightColors.surface2
    : AppColors.surface2;

Color _surface3(BuildContext ctx) => _isLight(ctx)
    ? LightColors.surface2
    : AppColors.surface3;

Color _border(BuildContext ctx) => _isLight(ctx)
    ? LightColors.border
    : AppColors.border;

Color _border2(BuildContext ctx) => _isLight(ctx)
    ? LightColors.border2
    : AppColors.border2;

Color _primary(BuildContext ctx) =>
    Theme.of(ctx).colorScheme.primary;

Color _text1(BuildContext ctx) => _isLight(ctx)
    ? LightColors.text1
    : AppColors.text1;

Color _text2(BuildContext ctx) => _isLight(ctx)
    ? LightColors.text2
    : AppColors.text2;

Color _text3(BuildContext ctx) => _isLight(ctx)
    ? LightColors.text3
    : AppColors.text3;

List<BoxShadow> _cardShadow(BuildContext ctx) => _isLight(ctx)
    ? const [
        BoxShadow(
            color: LightColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 2)),
      ]
    : [];

// ─── Glass Card ─────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double radius;
  final Color? background;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.radius = 18,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? _surface(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? _border(context),
          width: 1,
        ),
        boxShadow: _cardShadow(context),
      ),
      child: child,
    );
  }
}

// ─── Primary Button ─────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? _primary(context);
    final onColor = textColor ??
        (_isLight(context) ? Colors.white : const Color(0xFF021015));
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: btnColor.withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onColor,
                  ),
                ),
              )
            : Center(
                child: Text(
                  label,
                  style: AppTextStyles.subheading(color: onColor),
                ),
              ),
      ),
    );
  }
}

// ─── Secondary Button ────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _surface2(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border(context)),
          boxShadow: _isLight(context)
              ? [
                  const BoxShadow(
                      color: LightColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 1))
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(label,
                style: AppTextStyles.bodyMedium(color: _text2(context))),
          ],
        ),
      ),
    );
  }
}

// ─── Input Field ─────────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final primary = _primary(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTextStyles.labelOf(context),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _focused
                    ? primary.withOpacity(0.6)
                    : _border(context),
                width: _focused ? 1.5 : 1,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                          color: primary.withOpacity(0.08),
                          blurRadius: 12,
                          spreadRadius: 2)
                    ]
                  : _cardShadow(context),
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              style: AppTextStyles.body(color: _text1(context)),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyles.body(color: _text3(context)),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Status Badge ────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool pulsing;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.pulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulsing) ...[
            _PulsingDot(color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.label(color: color).copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text.toUpperCase(), style: AppTextStyles.labelOf(context)),
    );
  }
}

// ─── Divider with text ───────────────────────────────────────
class TextDivider extends StatelessWidget {
  final String text;
  const TextDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = _border(context);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: AppTextStyles.labelOf(context)),
        ),
        Expanded(child: Container(height: 1, color: dividerColor)),
      ],
    );
  }
}

// ─── Progress Row ────────────────────────────────────────────
class ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const ProgressRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMediumOf(context)),
            Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.bodyMedium(color: color)
                  .copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: _surface2(context),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Settings Item ───────────────────────────────────────────
class SettingsItem extends StatelessWidget {
  final Widget icon;
  final Color iconBg;
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    this.sublabel,
    this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border2(context)),
          boxShadow: _cardShadow(context),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium(
                      color: labelColor ?? _text1(context),
                    ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(sublabel!,
                        style: AppTextStyles.captionOf(context)),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: _text3(context), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Switch ───────────────────────────────────────────
class AppToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(AppToggle old) {
    super.didUpdateWidget(old);
    widget.value ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = _primary(context);
    final offColor = _isLight(context)
        ? const Color(0xFFCBD5E0)
        : AppColors.surface3;
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final on = _anim.value > 0.5;
          return Container(
            width: 42,
            height: 24,
            decoration: BoxDecoration(
              color: on ? primary : offColor,
              borderRadius: BorderRadius.circular(100),
              boxShadow: on
                  ? [
                      BoxShadow(
                          color: primary.withOpacity(0.25),
                          blurRadius: 10)
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Align(
                alignment: Alignment.lerp(
                  Alignment.centerLeft,
                  Alignment.centerRight,
                  _anim.value,
                )!,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Bottom Navigation Bar ───────────────────────────────────
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Learning'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    final light = _isLight(context);
    final activeColor = _primary(context);
    final inactiveColor = _text3(context);
    final bgColor = _surface(context);
    final borderColor = _border(context);

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                )
              ]
            : [],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          final (activeIcon, inactiveIcon, label) = items[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? activeColor.withOpacity(light ? 0.1 : 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        active ? activeIcon : inactiveIcon,
                        key: ValueKey(active),
                        color: active ? activeColor : inactiveColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label.toUpperCase(),
                      style: AppTextStyles.label(
                        color: active ? activeColor : inactiveColor,
                      ).copyWith(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Mesh / subtle background ────────────────────────────────
class MeshBackground extends StatelessWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final light = _isLight(context);
    final primary = _primary(context);
    final secondary = Theme.of(context).colorScheme.secondary;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -1.0),
                radius: 1.2,
                colors: [
                  primary.withOpacity(light ? 0.05 : 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, 1.0),
                radius: 1.0,
                colors: [
                  secondary.withOpacity(light ? 0.04 : 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ─── Back Button (reusable) ──────────────────────────────────
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _border(context)),
          boxShadow: _cardShadow(context),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _text2(context),
          size: 14,
        ),
      ),
    );
  }
}

// ─── Accent chip ─────────────────────────────────────────────
class AccentChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const AccentChip({
    super.key,
    required this.label,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : _surface2(context),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? color.withOpacity(0.35) : _border(context),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(
            color: selected ? color : _text3(context),
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
