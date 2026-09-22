import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final IconData? navIcon;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.visibility,
    this.onBack,
    this.onForward,
    this.navIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            if (onBack != null)
              _MinimalNavButton(
                icon: navIcon ?? Icons.arrow_back_ios_new,
                onTap: onBack!,
              ),
          ],
        ),
      ),
    );
  }
}

class _MinimalNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MinimalNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}

class BadgeTag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const BadgeTag({
    super.key,
    required this.text,
    this.color = AppTheme.primaryPurple,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.countBadgeHorizontalPadding,
        vertical: AppTheme.countBadgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bgPurple.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppTheme.numberBoxRadius),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppTheme.textSecondary,
              fontSize: AppTheme.subtitleFontSize,
              fontWeight: AppTheme.badgeWeight,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class PlayerChip extends StatelessWidget {
  final String name;
  final Color dotColor;
  final VoidCallback? onRemove;

  const PlayerChip({
    super.key,
    required this.name,
    required this.dotColor,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.chipHorizontalPadding,
        vertical: AppTheme.chipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          if (onRemove != null)
            Container(
              width: AppTheme.chipDotSize,
              height: AppTheme.chipDotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.bgDark.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppTheme.textPrimary,
              fontSize: AppTheme.chipFontSize,
              fontWeight: AppTheme.chipWeight,
            ),
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              color: AppTheme.textMuted,
              size: AppTheme.chipCloseIconSize,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? leadingBadge;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.leadingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing != null) trailing!,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  if (leadingBadge != null) ...[
                    const SizedBox(width: 10),
                    leadingBadge!,
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool glow;
  final double size;

  const IconCircle({
    super.key,
    required this.icon,
    this.color = AppTheme.primaryPurple,
    this.glow = false,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(glow ? 0.25 : 0.2),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class BottomActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final IconData rightIcon;
  final Color leftColor;
  final Color rightColor;
  final VoidCallback? onTap;
  final bool showLeftGlow;
  final bool showRightGlow;

  const BottomActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    required this.rightIcon,
    this.leftColor = AppTheme.primaryPurple,
    this.rightColor = AppTheme.primaryPurple,
    this.onTap,
    this.showLeftGlow = true,
    this.showRightGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Icon(leftIcon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(rightIcon, color: Colors.white.withOpacity(0.9), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
