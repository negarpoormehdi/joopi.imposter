import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/game_state.dart';

class GameplayScreen extends StatefulWidget {
  final GameState gameState;
  const GameplayScreen({super.key, required this.gameState});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  int _roundNumber = 1;
  final int _totalRounds = 3;
  late int _timeSeconds;
  late int _totalTimeSeconds;
  bool _isPaused = false;
  bool _isEnded = false;
  Timer? _timer;
  bool _soundOn = true;

  int _currentSpeakerIndex = 0;
  int _targetSpeakerIndex = 1;

  bool _showLocation = false;

  @override
  void initState() {
    super.initState();
    _totalTimeSeconds = widget.gameState.roundTimeSeconds;
    _timeSeconds = _totalTimeSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isEnded) {
        setState(() {
          if (_timeSeconds > 0) {
            _timeSeconds--;
          } else {
            _isEnded = true;
            timer.cancel();
            _showTimeUpDialog();
          }
        });
      }
    });
  }

  void _showTimeUpDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'زمان تموم شد!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          content: const Text(
            'حالا جاسوس حدس بزند یا همه رای‌گیری کنند',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'باشه',
                style: TextStyle(color: AppTheme.primaryPurple),
              ),
            ),
          ],
        ),
      );
    });
  }

  String get _formattedTime {
    final mins = _timeSeconds ~/ 60;
    final secs = _timeSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}'
        .toFa;
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _addOneMinute() {
    setState(() {
      _timeSeconds += 60;
      _totalTimeSeconds = _totalTimeSeconds < _timeSeconds
          ? _timeSeconds
          : _totalTimeSeconds;
    });
  }

  void _advanceSpeaker() {
    final total = widget.gameState.playerCount;
    if (total < 2) return;
    setState(() {
      _currentSpeakerIndex = (_currentSpeakerIndex + 1) % total;
      _targetSpeakerIndex = (_currentSpeakerIndex + 1) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.gameState.players;
    final totalPlayers = players.length;
    final spyCount = widget.gameState.spyCount;
    final speaker = players[_currentSpeakerIndex % totalPlayers];
    final target = players[_targetSpeakerIndex % totalPlayers];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTimerSection(),
              const SizedBox(height: 28),
              _buildControlButtons(),
              const SizedBox(height: 22),
              _buildDayTurnSection(speaker, target),
              const SizedBox(height: 14),
              _buildPlayersInGameSection(totalPlayers, spyCount),
              const SizedBox(height: 14),
              _buildLocationSection(),
              const SizedBox(height: 14),
              _buildSpyHintSection(),
              const SizedBox(height: 20),
              _buildEndVotingButton(),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'جاسوس لو رفت یا قصد حدس دارد؟ لمس کنید  ',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.circle,
                              size: 9,
                              color: AppTheme.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.pinkPurple],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'گفتگو و پیدا کردن جاسوس',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'راند ${_roundNumber.toFa} • همه با هم صحبت کنید',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardBg,
                    border: Border.all(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final progress = _totalTimeSeconds == 0
        ? 0.0
        : (_timeSeconds / _totalTimeSeconds).clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 320,
              height: 320,
              child: CustomPaint(painter: _TimerPainter(progress: progress)),
            ),
            Positioned.fill(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bgPurple.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.circle,
                              size: 9,
                              color: AppTheme.pink,
                            ),
                          ),
                          Text(
                            _isEnded
                                ? 'پایان زمان'
                                : _isPaused
                                ? 'متوقف شده'
                                : 'زمان بازجویی و گفتگو',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: _isPaused
                                  ? AppTheme.orange
                                  : _isEnded
                                  ? AppTheme.red
                                  : AppTheme.lightPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: _timeSeconds < 60
                          ? AppTheme.red
                          : AppTheme.textPrimary,
                      fontSize: 88,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 18),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'راند ${_roundNumber.toFa} از ${_totalRounds.toFa}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'سرعت عادی',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppTheme.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.timer_outlined,
                          color: AppTheme.lightPurple,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardBg,
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: GestureDetector(
                onTap: () => setState(() => _soundOn = !_soundOn),
                child: Icon(
                  _soundOn
                      ? Icons.volume_up_outlined
                      : Icons.volume_off_outlined,
                  color: AppTheme.textPrimary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _togglePause,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.lightPurple],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.45),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _addOneMinute,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+۱ دقیقه'.toFa,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTurnSection(GamePlayer speaker, GamePlayer target) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوبت طرح پرسش هوشمندانه',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildTurnTag(
                          speaker.name,
                          active: true,
                          color: AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'می‌پرسد از',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppTheme.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTurnTag(target.name, active: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardBgLight,
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '؟',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnTag(
    String name, {
    bool active = false,
    Color color = AppTheme.primaryPurple,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.22) : AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color.withValues(alpha: 0.6) : Colors.transparent,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: active ? color : AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildPlayersInGameSection(int totalPlayers, int spyCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مظنونین حاضر در بازی',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.gameState.activeCategories.join(' • ')}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildSmallBadge(
                          text: '${totalPlayers.toFa} بازیکن',
                          color: AppTheme.primaryPurple,
                          bg: AppTheme.primaryPurple.withValues(alpha: 0.15),
                        ),
                        const SizedBox(width: 10),
                        _buildSmallBadge(
                          text: '${spyCount.toFa} جاسوس',
                          color: AppTheme.pink,
                          bg: AppTheme.red.withValues(alpha: 0.18),
                          dot: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgPurple.withValues(alpha: 0.6),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  color: AppTheme.lightPurple,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBadge({
    required String text,
    required Color color,
    required Color bg,
    bool dot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot) ...[
              Container(
                margin: const EdgeInsets.only(left: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ],
            Text(
              text,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => setState(() => _showLocation = !_showLocation),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'یادآوری مکان بازی',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _showLocation
                            ? 'توجه: جاسوس نباید ببیند'
                            : 'مشاهده امن و محرمانه کلمه',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSmallBadge(
                        text: _showLocation
                            ? widget.gameState.location
                            : 'دیدن مکان',
                        color: AppTheme.primaryPurple,
                        bg: AppTheme.bgPurple.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardBgLight,
                    border: Border.all(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Icon(
                    _showLocation
                        ? Icons.location_on_rounded
                        : Icons.location_on_outlined,
                    color: AppTheme.lightPurple,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpyHintSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.32),
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppTheme.primaryPurple.withValues(alpha: 0.9),
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'استراتژی بازی:',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'طوری جواب دهید که شهروندان بفهمند شما باخبر هستید، اما مکان لو نرود!',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'راهنمای بازی',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndVotingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.55),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgPurple.withValues(alpha: 0.7),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.6),
                  ),
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  color: AppTheme.lightPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Text(
                            '🔥 پایان زمان و شروع رأی‌گیری',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'آماده‌سازی برای شناسایی مظنون',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.22),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _timer?.cancel();
                      _isEnded = true;
                      _showTimeUpDialog();
                    });
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.bgDark,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;

  _TimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    final bgPaint = Paint()
      ..color = AppTheme.cardBg.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final dashPaint = Paint()
      ..color = AppTheme.primaryPurple.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const dashCount = 60;
    const dashAngle = (2 * pi) / dashCount;
    const dashLen = 7.0;
    final innerR = radius - 22;
    final outerR = radius - 12;

    for (var i = 0; i < dashCount; i++) {
      final angle = -pi / 2 + i * dashAngle;
      final start = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );
      final end = Offset(
        center.dx + outerR * cos(angle),
        center.dy + outerR * sin(angle),
      );
      canvas.drawLine(start, end, dashPaint);
    }

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -1.57,
        endAngle: 4.71,
        colors: const [
          AppTheme.pink,
          AppTheme.pinkPurple,
          AppTheme.primaryPurple,
          AppTheme.lightPurple,
        ],
        stops: const [0.0, 0.28, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
