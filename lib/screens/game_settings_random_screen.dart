import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'game_settings_screen.dart';

class GameSettingsRandomScreen extends StatefulWidget {
  const GameSettingsRandomScreen({super.key});

  @override
  State<GameSettingsRandomScreen> createState() =>
      _GameSettingsRandomScreenState();
}

class _GameSettingsRandomScreenState extends State<GameSettingsRandomScreen> {
  int _playersCount = 5;
  int _spyCount = 1;
  int _roundTime = 5;
  bool _showLocation = true;
  bool _soundOn = true;

  final List<Map<String, dynamic>> _players = [
    {'name': 'مریم', 'color': AppTheme.pinkPurple},
    {'name': 'نیما', 'color': AppTheme.blue},
    {'name': 'سارا', 'color': AppTheme.pink},
    {'name': 'علی (شما)', 'color': AppTheme.lightPurple},
    {'name': 'رضا', 'color': AppTheme.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: 'تنظیمات بازی',
                subtitle: 'اتاق بازی دورهمی',
                onBack: () => Navigator.of(context).pop(),
                navIcon: Icons.arrow_forward_ios,
              ),
              _buildPlayersCountSection(),
              _buildPlayersListSection(),
              _buildSpyCountSection(),
              _buildRoundTimeSection(),
              _buildOptionsSection(),
              const SizedBox(height: 16),
              BottomActionButton(
                title: 'شروع بازی و توزیع نقش‌ها',
                subtitle: 'آماده‌سازی کارت‌های مخفی برای بازیکن اول',
                leftIcon: Icons.arrow_forward,
                rightIcon: Icons.group,
                leftColor: AppTheme.lightPurple,
                rightColor: AppTheme.primaryPurple,
                showLeftGlow: true,
                showRightGlow: false,
                onTap: () {},
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Center(
                  child: Text(
                    'قوانین استاندارد جاسوس • نسخه کلاسیک',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersCountSection() {
    return SectionCard(
      child: Column(
        children: [
          SectionHeader(
            title: 'چند نفر بازی می‌کنید؟',
            subtitle: 'تعداد کل بازیکن‌ها',
            leadingBadge: const BadgeTag(
              text: '۵ نفر',
              color: AppTheme.primaryPurple,
              icon: Icons.water_drop_outlined,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.remove,
                onTap: () {
                  if (_playersCount > 3) {
                    setState(() => _playersCount--);
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final percent = ((_playersCount - 3) / 7);
                        return Row(
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * percent,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.primaryPurple,
                                      AppTheme.pinkPurple,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final percent = ((_playersCount - 3) / 7);
                          return Row(
                            children: [
                              SizedBox(
                                width: constraints.maxWidth * percent - 18,
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.primaryPurple,
                                      AppTheme.lightPurple,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppTheme.cardBg,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryPurple.withOpacity(
                                        0.5,
                                      ),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildCircleButton(
                icon: Icons.add,
                onTap: () {
                  if (_playersCount < 10) {
                    setState(() => _playersCount++);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '۱۵ نفر',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                textDirection: TextDirection.rtl,
              ),
              Text(
                '۳ نفر (حداقل)',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cardBgLight,
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 28),
      ),
    );
  }

  Widget _buildPlayersListSection() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconCircle(
                icon: Icons.group,
                color: AppTheme.primaryPurple,
                glow: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'اسامی بازیکنان',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 10),
                        const BadgeTag(
                          text: 'اسامی رندوم',
                          color: AppTheme.darkPurple,
                          icon: Icons.shuffle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'شخصی سازی نام‌ها با استفاده از پیش فرض',
                      style: TextStyle(
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
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              PlayerChip(name: 'مریم', dotColor: AppTheme.pinkPurple),
              PlayerChip(name: 'نیما', dotColor: AppTheme.blue),
              PlayerChip(name: 'سارا', dotColor: AppTheme.pink),
              PlayerChip(name: 'علی (شما)', dotColor: AppTheme.lightPurple),
              const SizedBox(width: 10),
              PlayerChip(name: 'رضا', dotColor: AppTheme.red),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBgLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'نام بازیکن جدید....',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'افزودن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.add, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpyCountSection() {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryPurple.withOpacity(0.15),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardBg,
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.5),
                  width: 3,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.lightPurple],
                  ),
                ),
                child: const Icon(Icons.circle, color: Colors.white, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'تعداد جاسوس‌ها',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 4),
                Text(
                  'افرادی که مکان را نمی‌دانند',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardBgLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSmallButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_spyCount > 1) {
                      setState(() => _spyCount--);
                    }
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_spyCount',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSmallButton(
                  icon: Icons.add,
                  onTap: () {
                    if (_spyCount < _playersCount - 2) {
                      setState(() => _spyCount++);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildRoundTimeSection() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconCircle(
                icon: Icons.timer_outlined,
                color: AppTheme.primaryPurple,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'زمان هر راند بازی',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 10),
                        BadgeTag(
                          text: '$_roundTime دقیقه',
                          color: AppTheme.darkPurple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeOption(3, '۳ دقیقه'),
              _buildTimeOption(5, '۵ دقیقه', active: true),
              _buildTimeOption(8, '۸ دقیقه'),
              _buildTimeOption(10, '۱۰ دقیقه'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(int value, String label, {bool active = false}) {
    return GestureDetector(
      onTap: () => setState(() => _roundTime = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.lightPurple],
                )
              : null,
          color: active ? null : AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? AppTheme.primaryPurple
                : AppTheme.primaryPurple.withOpacity(0.3),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.5),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 4, bottom: 6),
              child: Text(
                'قوانین جانبی و سناریو',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionRow(
            title: 'نمایش مکان‌های حدسی برای جاسوس',
            subtitle: 'لیست مکان‌ها به شانس حدس داشته باشد',
            value: _showLocation,
            onChanged: (v) => setState(() => _showLocation = v),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppTheme.cardBgLight),
          const SizedBox(height: 16),
          _buildOptionRow(
            title: 'لرزش و افکت‌های صوتی',
            subtitle: 'هنگام تحویل گوشی به نفر بعدی و پایان زمان',
            value: _soundOn,
            onChanged: (v) => setState(() => _soundOn = v),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryPurple,
            activeTrackColor: AppTheme.primaryPurple.withOpacity(0.4),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.cardBgLight,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppTheme.primaryPurple,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
