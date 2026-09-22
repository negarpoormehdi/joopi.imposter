import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  bool _paintCanvasMode = false;

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
    if (newCount < 3 || newCount > 15) return;
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
    if (_players.length >= 15) return;
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
      paintCanvasModeEnabled: _paintCanvasMode,
      showLocationListForSpy: _showLocation,
      soundEnabled: _soundOn,
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
                icon: Icons.tune_rounded,
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
                      fontFamily: AppTheme.fontFamily,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعداد کل بازیکن‌ها',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: AppTheme.largeSubtitleFontSize,
                        fontWeight: AppTheme.subtitleWeight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'چند نفر بازی می‌کنید؟',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.largeTitleFontSize,
                        fontWeight: AppTheme.titleWeight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.numberBoxHorizontalPadding,
                  vertical: AppTheme.numberBoxVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bgPurple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(AppTheme.numberBoxRadius),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightPurple.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      '${_playersCount.toFa}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white,
                        fontSize: AppTheme.bigNumberFontSize,
                        fontWeight: AppTheme.titleWeight,
                        height: 1,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'نفر',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: AppTheme.smallNumberFontSize,
                          fontWeight: AppTheme.subtitleWeight,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                _buildRoundedSquareButton(
                  icon: Icons.remove,
                  onTap: () => _setPlayersCount(_playersCount - 1),
                ),
                // const SizedBox(width: 2),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8,
                      activeTrackColor: AppTheme.cardBgLight,
                      inactiveTrackColor: AppTheme.cardBgLight,
                      thumbColor: AppTheme.textSecondary,
                      overlayColor: Colors.transparent,
                      thumbShape: const _NeonCircleSliderThumb(),
                    ),
                    child: Slider(
                      value: _playersCount.toDouble(),
                      min: 3,
                      max: 15,
                      onChanged: (v) => _setPlayersCount(v.round()),
                    ),
                  ),
                ),
                // const SizedBox(width: 2),
                _buildRoundedSquareButton(
                  icon: Icons.add,
                  onTap: () => _setPlayersCount(_playersCount + 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '۳ نفر (حداقل)',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.textMuted,
                    fontSize: AppTheme.subtitleFontSize,
                    fontWeight: AppTheme.badgeWeight,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '۱۵ نفر',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.textMuted,
                    fontSize: AppTheme.subtitleFontSize,
                    fontWeight: AppTheme.badgeWeight,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppTheme.controlButtonSize,
        height: AppTheme.controlButtonSize,
        decoration: BoxDecoration(
          color: AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(AppTheme.controlButtonRadius),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.textPrimary,
          size: AppTheme.controlIconSize,
        ),
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
              Container(
                width: AppTheme.playerIconBoxSize,
                height: AppTheme.playerIconBoxSize,
                decoration: BoxDecoration(
                  color: AppTheme.bgPurple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(
                    AppTheme.playerIconBoxRadius,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                  ),
                ),
                child: Icon(
                  Icons.group,
                  color: AppTheme.textSecondary,
                  size: AppTheme.playerIconSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اسامی بازیکنان',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.largeTitleFontSize,
                        fontWeight: AppTheme.titleWeight,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      'مدیریت نوبت و کارت‌های اختصاصی',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: AppTheme.subtitleFontSize,
                        fontWeight: AppTheme.subtitleWeight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.countBadgeHorizontalPadding,
                  vertical: AppTheme.countBadgeVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bgPurple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(AppTheme.numberBoxRadius),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '${_playersCount.toFa} نفر ثبت شده',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.subtitleFontSize,
                    fontWeight: AppTheme.badgeWeight,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: AppTheme.chipSpacing,
              runSpacing: AppTheme.chipSpacing,
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
          Container(
            padding: EdgeInsets.all(AppTheme.addRowPadding),
            decoration: BoxDecoration(
              color: AppTheme.bgDark,
              borderRadius: BorderRadius.circular(AppTheme.addRowRadius),
              border: Border.all(
                color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _nameController,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.inputFontSize,
                        fontWeight: AppTheme.inputWeight,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addPlayer(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'نام بازیکن جدید....',
                        hintStyle: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.textMuted,
                          fontSize: AppTheme.inputFontSize,
                          fontWeight: AppTheme.subtitleWeight,
                        ),
                        hintTextDirection: TextDirection.rtl,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _addPlayer,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.addButtonHorizontalPadding,
                      vertical: AppTheme.addButtonVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.lightPurple],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.addButtonRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: AppTheme.addButtonIconSize,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'افزودن',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: AppTheme.buttonChipFontSize,
                            fontWeight: AppTheme.buttonWeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpyCountSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.4),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgPurple.withOpacity(0.45), AppTheme.cardBgLight],
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            _buildSpyIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تعداد جاسوس ها',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.largeTitleFontSize,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'افرادی که مکان را نمی دانند',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _buildSpyCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpyIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.55),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEF5540),
          gradient: const RadialGradient(
            colors: [Color(0xFFFF6B5A), Color(0xFFE13E2F)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [SvgPicture.asset('assets/spy.svg')],
        ),
      ),
    );
  }

  Widget _spyGlass() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2.5),
      ),
    );
  }

  Widget _buildSpyCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF120A2A),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSpyCounterButton(
              icon: Icons.add,
              onTap: () {
                if (_spyCount < _maxSpy) setState(() => _spyCount++);
              },
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 26,
              child: Center(
                child: Text(
                  '${_spyCount.toFa}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.bigNumberFontSize,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildSpyCounterButton(
              icon: Icons.remove,
              onTap: () {
                if (_spyCount > 1) setState(() => _spyCount--);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpyCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2A1A50),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.45),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppTheme.playerIconBoxSize,
                height: AppTheme.playerIconBoxSize,
                decoration: BoxDecoration(
                  color: AppTheme.bgPurple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(
                    AppTheme.playerIconBoxRadius,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                  ),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: AppTheme.textSecondary,
                  size: AppTheme.playerIconSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'زمان هر راند بازی',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.largeTitleFontSize,
                            fontWeight: AppTheme.titleWeight,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BadgeTag(
                text: '${_roundTime.toFa} دقیقه',
                color: AppTheme.darkPurple,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeOption(3, '۳ دقیقه'),
                const SizedBox(width: 8),
                _buildTimeOption(5, '۵ دقیقه'),
                const SizedBox(width: 8),
                _buildTimeOption(8, '۸ دقیقه'),
                const SizedBox(width: 8),
                _buildTimeOption(10, '۱۰ دقیقه'),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.lightPurple],
                )
              : null,
          color: active ? null : AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(14),
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
            fontFamily: AppTheme.fontFamily,
            color: active ? Colors.white : AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
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
              Container(
                width: AppTheme.playerIconBoxSize,
                height: AppTheme.playerIconBoxSize,
                decoration: BoxDecoration(
                  color: AppTheme.bgPurple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(
                    AppTheme.playerIconBoxRadius,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                  ),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: AppTheme.textSecondary,
                  size: AppTheme.playerIconSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دسته‌بندی کلمات',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.largeTitleFontSize,
                        fontWeight: AppTheme.titleWeight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      'انتخاب موضوعات بازی و افزودن کلمه',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: AppTheme.subtitleFontSize,
                        fontWeight: AppTheme.subtitleWeight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 0),
              BadgeTag(
                text: '${activeList.length} موضوع فعال',
                color: AppTheme.darkPurple,
              ),
              const SizedBox(width: 4),
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
            alignment: Alignment.centerRight,
            child: Text(
              '+۱۴۰ کلمه',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
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
        // width: 44,
        // height: 44,

        child: Icon(icon, color: AppTheme.textMuted, size: 18),
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
                  fontFamily: AppTheme.fontFamily,
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
            title: 'بوم نقاشی جاسوس (مود نقاشی)',
            subtitle: 'به جای گفتگو، هر بازیکن روی بوم نقاشی می‌کند (غیرفعال)',
            value: _paintCanvasMode,
            onChanged: (v) => setState(() => _paintCanvasMode = v),
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
        // Container(
        //   width: 10,
        //   height: 10,
        //   margin: const EdgeInsets.only(top: 8),
        //   decoration: const BoxDecoration(
        //     color: AppTheme.primaryPurple,
        //     shape: BoxShape.circle,
        //   ),
        // ),
        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.largeTitleFontSize,
                  fontWeight: AppTheme.titleWeight,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppTheme.textMuted,
                  fontSize: AppTheme.subtitleFontSize,
                  fontWeight: AppTheme.subtitleWeight,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        SizedBox(
          height: 32,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.textPrimary,
            activeTrackColor: AppTheme.pinkPurple,
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.cardBgLight,
          ),
        ),
      ],
    );
  }
}

class _NeonCircleSliderThumb extends SliderComponentShape {
  const _NeonCircleSliderThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(30, 30);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    const radius = 10.0;
    const borderWidth = 3.0;

    final shadowPaint = Paint()
      ..color = AppTheme.lightPurple.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 2, shadowPaint);

    final borderPaint = Paint()
      ..color = AppTheme.bgDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    final fillPaint = Paint()..color = AppTheme.lightPurple;
    canvas.drawCircle(center, radius - borderWidth / 2, fillPaint);
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
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppTheme.textPrimary,
              fontSize: AppTheme.chipFontSize,
              fontWeight: AppTheme.chipWeight,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
