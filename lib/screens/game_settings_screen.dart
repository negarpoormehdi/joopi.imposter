import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/game_state.dart';
import 'topics_screen.dart';
import 'role_distribution_flow_screen.dart';

class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen({super.key});

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  int _spyCount = 1;
  int _roundTime = 5;
  bool _showLocation = true;
  bool _soundOn = true;

  final List<String> _defaultNames = const [
    'علی',
    'سارا',
    'نیما',
    'مریم',
    'رضا',
    'مهدی',
    'پریسا',
    'امیر',
    'نگار',
    'بهنام',
  ];

  final List<Color> _playerColors = const [
    AppTheme.lightPurple,
    AppTheme.pink,
    AppTheme.blue,
    AppTheme.pinkPurple,
    AppTheme.red,
    AppTheme.green,
    AppTheme.orange,
    Color(0xFF06B6D4),
    AppTheme.primaryPurple,
    Color(0xFFF472B6),
  ];

  late List<String> _players;
  late Set<String> _activeCategories;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _players = ['علی (شما)', 'سارا', 'نیما'];
    _activeCategories = {'مکان‌ها', 'مشاغل', 'اشیاء'};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _playersCount => _players.length;
  int get _maxSpy => (_playersCount - 2).clamp(1, 5);

  void _setPlayersCount(int newCount) {
    if (newCount < 3 || newCount > 10) return;
    setState(() {
      while (_players.length < newCount) {
        final idx = _players.length - 1;
        final candidate = _defaultNames[idx % _defaultNames.length];
        var finalName = candidate;
        var counter = 2;
        while (_players.contains(finalName)) {
          finalName = '$candidate $counter';
          counter++;
        }
        _players.add(finalName);
      }
      while (_players.length > newCount) {
        _players.removeLast();
      }
      if (_spyCount > _maxSpy) _spyCount = _maxSpy;
    });
  }

  void _addPlayer() {
    final text = _nameController.text.trim();
    final name = text.isEmpty
        ? () {
            final idx = _players.length;
            return _defaultNames[idx % _defaultNames.length];
          }()
        : text;
    if (_players.length >= 10) return;
    setState(() {
      final finalName = _players.contains(name)
          ? '$name (${_players.length + 1})'
          : name;
      _players.add(finalName);
      if (_spyCount > _maxSpy) _spyCount = _maxSpy;
      _nameController.clear();
    });
  }

  void _removePlayerAt(int index) {
    if (_players.length <= 3) return;
    setState(() {
      _players.removeAt(index);
      if (_spyCount > _maxSpy) _spyCount = _maxSpy;
    });
  }

  Future<void> _openTopics() async {
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => TopicsScreen(initialSelection: _activeCategories),
      ),
    );
    if (result != null && mounted) {
      setState(() => _activeCategories = result);
    }
  }

  void _startGame() {
    if (_players.length < 3) return;
    final state = GameStateBuilder(
      playerNames: List<String>.from(_players),
      spyCount: _spyCount,
      roundTimeMinutes: _roundTime,
      activeCategories: _activeCategories,
    ).build();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleDistributionFlowScreen(gameState: state),
      ),
    );
  }

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
              _buildCategoriesSection(),
              _buildOptionsSection(),
              const SizedBox(height: 16),
              BottomActionButton(
                title: 'شروع بازی و توزیع نقش‌ها',
                subtitle: 'آماده‌سازی کارت‌های مخفی برای بازیکنان',
                leftIcon: Icons.play_arrow,
                rightIcon: Icons.arrow_forward,
                rightColor: AppTheme.lightPurple,
                showLeftGlow: true,
                showRightGlow: false,
                onTap: _startGame,
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
            leadingBadge: BadgeTag(
              text: 'بازیکن $_playersCount نفر',
              color: AppTheme.primaryPurple,
              icon: Icons.water_drop,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.remove,
                onTap: () => _setPlayersCount(_playersCount - 1),
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
                        final percent = ((_playersCount - 3) / 7).clamp(
                          0.0,
                          1.0,
                        );
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
                          final percent = ((_playersCount - 3) / 7).clamp(
                            0.0,
                            1.0,
                          );
                          final totalW = constraints.maxWidth;
                          final indicatorSize = 36.0;
                          final leftOffset =
                              (totalW * percent - indicatorSize / 2).clamp(
                                0.0,
                                totalW - indicatorSize,
                              );
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: leftOffset),
                              width: indicatorSize,
                              height: indicatorSize,
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
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryPurple.withOpacity(
                                      0.6,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
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
                onTap: () => _setPlayersCount(_playersCount + 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '۱۰ نفر',
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
                        BadgeTag(
                          text: '$_playersCount نفر ثبت شده',
                          color: AppTheme.darkPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'مدیریت نوبت و کارت‌های اختصاصی',
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
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _players.length; i++)
                  PlayerChip(
                    name: _players[i],
                    dotColor: _playerColors[i % _playerColors.length],
                    onRemove: () => _removePlayerAt(i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addPlayer(),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: AppTheme.cardBgLight,
                    hintText: 'نام بازیکن جدید....',
                    hintStyle: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppTheme.primaryPurple.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addPlayer,
                child: Container(
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
              color: Colors.red.withOpacity(0.15),
              border: Border.all(color: Colors.red.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20),
              ],
            ),
            child: const Icon(Icons.face, color: Colors.red, size: 36),
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
                    if (_spyCount > 1) setState(() => _spyCount--);
                  },
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      '$_spyCount',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSmallButton(
                  icon: Icons.add,
                  onTap: () {
                    if (_spyCount < _maxSpy) setState(() => _spyCount++);
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
              _buildTimeOption(5, '۵ دقیقه'),
              _buildTimeOption(8, '۸ دقیقه'),
              _buildTimeOption(10, '۱۰ دقیقه'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(int value, String label) {
    final active = _roundTime == value;
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

  Widget _buildCategoriesSection() {
    final activeList = _categories
        .where((c) => _activeCategories.contains(c['name']))
        .toList();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconCircle(
                icon: Icons.layers_outlined,
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
                          'دسته‌بندی کلمات',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 10),
                        BadgeTag(
                          text: '${activeList.length} موضوع فعال',
                          color: AppTheme.darkPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'انتخاب موضوعات بازی و افزودن کلمه',
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
              const SizedBox(width: 10),
              _buildRoundNavButton(Icons.arrow_forward_ios, _openTopics),
            ],
          ),
          const SizedBox(height: 20),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in _categories)
                  CategoryChip(
                    label: c['name'] as String,
                    color: c['color'] as Color,
                    active: _activeCategories.contains(c['name']),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '+۱۴۰ کلمه',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'مکان‌ها', 'color': AppTheme.pink},
    {'name': 'مشاغل', 'color': AppTheme.pinkPurple},
    {'name': 'اشیاء', 'color': AppTheme.blue},
    {'name': 'حیوانات', 'color': AppTheme.red},
  ];

  Widget _buildRoundNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.cardBgLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 18),
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
            subtitle: 'لیست مکان‌ها را به شانس حدس نشان بدهد',
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

class CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;

  const CategoryChip({
    super.key,
    required this.label,
    required this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.2) : AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? color.withOpacity(0.6)
              : AppTheme.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
