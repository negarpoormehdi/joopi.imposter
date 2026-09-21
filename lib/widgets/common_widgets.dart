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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            if (onBack != null)
              _HeaderNavButton(
                icon: navIcon ?? Icons.arrow_back_ios_new,
                onTap: onBack!,
              )
            else
              const _HeaderNavButton(
                icon: Icons.arrow_forward_ios,
                onTap: null,
                isPlaceholder: true,
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _HeaderLogoIcon(icon: icon),
          ],
        ),
      ),
    );
  }
}

class _HeaderLogoIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderLogoIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppTheme.lightPurple,
            AppTheme.primaryPurple,
            AppTheme.pinkPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pinkPurple.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.22), Colors.transparent],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
          Icon(
            icon,
            color: Colors.white,
            size: 34,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPlaceholder;

  const _HeaderNavButton({
    required this.icon,
    this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardBg,
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isPlaceholder && onTap == null
            ? AppTheme.textMuted.withOpacity(0.5)
            : AppTheme.textPrimary,
        size: 23,
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
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
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
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
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                color: AppTheme.textMuted,
                size: AppTheme.chipCloseIconSize,
              ),
            ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 8),
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.cardBg, AppTheme.cardBgLight],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [leftColor, AppTheme.lightPurple],
                ),
                boxShadow: showLeftGlow
                    ? [
                        BoxShadow(
                          color: leftColor.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(leftIcon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.rtl,
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
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rightColor.withOpacity(0.2),
                boxShadow: showRightGlow
                    ? [
                        BoxShadow(
                          color: rightColor.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Icon(rightIcon, color: rightColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
