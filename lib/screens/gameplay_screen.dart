import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
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
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: 'گفتگو و پیدا کردن جاسوس',
                subtitle: 'راند اول • همه با هم صحبت کنید',
                onBack: () => Navigator.of(context).pop(),
                navIcon: Icons.arrow_forward_ios,
              ),
              const SizedBox(height: 20),
              _buildTimerSection(),
              const SizedBox(height: 24),
              _buildControlButtons(),
              const SizedBox(height: 16),
              _buildDayTurnSection(speaker, target),
              const SizedBox(height: 12),
              _buildPlayersInGameSection(totalPlayers, spyCount),
              const SizedBox(height: 12),
              _buildLocationSection(),
              const SizedBox(height: 12),
              _buildSpyHintSection(),
              const SizedBox(height: 16),
              BottomActionButton(
                title: 'پایان زمان و شروع رأی‌گیری',
                subtitle: 'آماده‌سازی برای شناسایی مظنون',
                leftIcon: Icons.check,
                rightIcon: Icons.arrow_back,
                leftColor: Colors.amber,
                rightColor: AppTheme.lightPurple,
                showLeftGlow: true,
                showRightGlow: false,
                onTap: () {
                  setState(() {
                    _timer?.cancel();
                    _isEnded = true;
                    _showTimeUpDialog();
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'جاسوس لو رفت یا قصد حدس دارد؟ لمس کنید  ',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.circle,
                              size: 8,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(painter: _TimerPainter(progress: progress)),
            ),
            Positioned(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isPaused
                          ? Colors.amber.withOpacity(0.2)
                          : _isEnded
                          ? Colors.red.withOpacity(0.2)
                          : AppTheme.primaryPurple.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            _isPaused
                                ? Icons.pause_circle
                                : _isEnded
                                ? Icons.alarm
                                : Icons.circle,
                            size: 8,
                            color: _isPaused
                                ? Colors.amber
                                : _isEnded
                                ? Colors.red
                                : AppTheme.pink,
                          ),
                        ),
                        Text(
                          _isEnded
                              ? 'پایان زمان'
                              : _isPaused
                              ? 'متوقف شده'
                              : 'زمان بازجویی و گفتگو',
                          style: TextStyle(
                            color: _isPaused
                                ? Colors.amber
                                : _isEnded
                                ? Colors.red
                                : AppTheme.primaryPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      Text(
                        _formattedTime.characters.first,
                        style: TextStyle(
                          color: _timeSeconds < 60
                              ? Colors.redAccent
                              : AppTheme.textPrimary,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        _formattedTime.characters.elementAt(1),
                        style: TextStyle(
                          color: _timeSeconds < 60
                              ? Colors.redAccent
                              : AppTheme.textPrimary,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        ':',
                        style: TextStyle(
                          color: _timeSeconds < 60
                              ? Colors.redAccent
                              : AppTheme.primaryPurple,
                          fontSize: 70,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _formattedTime.characters.elementAt(3),
                        style: TextStyle(
                          color: _timeSeconds < 60
                              ? Colors.redAccent
                              : AppTheme.textPrimary,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        _formattedTime.characters.elementAt(4),
                        style: TextStyle(
                          color: _timeSeconds < 60
                              ? Colors.redAccent
                              : AppTheme.textPrimary,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'سرعت عادی',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'راند $_roundNumber از $_totalRounds',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.timer_outlined,
                          color: AppTheme.primaryPurple,
                          size: 18,
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
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.add,
            label: '+۱ دقیقه',
            onTap: _addOneMinute,
            isMain: false,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: _isPaused ? Icons.play_arrow : Icons.pause,
            label: '',
            onTap: _togglePause,
            isMain: true,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: _soundOn ? Icons.volume_up_outlined : Icons.volume_off,
            label: '',
            onTap: () => setState(() => _soundOn = !_soundOn),
            isMain: false,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isMain,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: isMain
          ? Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPaused
                      ? const [Colors.amber, Color(0xFFF472B6)]
                      : [AppTheme.primaryPurple, AppTheme.lightPurple],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isPaused ? Colors.amber : AppTheme.primaryPurple)
                        .withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            )
          : label.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppTheme.textPrimary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Icon(icon, color: AppTheme.textPrimary, size: 26),
            ),
    );
  }

  Widget _buildDayTurnSection(GamePlayer speaker, GamePlayer target) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildQuestionBubble(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'نوبت طرح پرسش هوشمندانه',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTurnTag(
                      speaker.name,
                      'می‌پرسد از',
                      active: true,
                      color: AppTheme.pink,
                    ),
                    const SizedBox(width: 8),
                    _buildTurnTag(target.name, 'نفر دوم', active: false),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _advanceSpeaker,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.swipe_left_alt,
                          color: AppTheme.lightPurple,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'رفتن به نوبت نفر بعدی',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios_outlined,
            textDirection: TextDirection.rtl,
            color: AppTheme.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBubble() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.cardBgLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: const Text(
        '؟',
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildTurnTag(
    String name,
    String role, {
    bool active = false,
    Color color = AppTheme.blue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.2) : AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color.withOpacity(0.6) : Colors.transparent,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: active ? color : AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildPlayersInGameSection(int totalPlayers, int spyCount) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const IconCircle(
            icon: Icons.groups_2_outlined,
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
                  children: const [
                    Text(
                      'مظنونین حاضر در بازی',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${widget.gameState.activeCategories.join(' • ')}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BadgeTag(
                      text: '$totalPlayers بازیکن',
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(width: 10),
                    BadgeTag(text: '$spyCount جاسوس', color: AppTheme.pink),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showLocation = !_showLocation),
            child: IconCircle(
              icon: _showLocation ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.primaryPurple,
              glow: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'یادآوری مکان بازی',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _showLocation
                        ? 'توجه: جاسوس نباید ببیند'
                        : 'مشاهده امن و محرمانه کلمه',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _showLocation = !_showLocation),
                    child: BadgeTag(
                      text: _showLocation
                          ? widget.gameState.location
                          : 'دیدن مکان',
                      color: AppTheme.primaryPurple,
                      icon: _showLocation ? Icons.visibility : Icons.visibility,
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

  Widget _buildSpyHintSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.cardBg, AppTheme.primaryPurple.withOpacity(0.1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primaryPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'استراتژی بازی: طوری جواب دهید که شهروندان بفهمند شما باخبر هستید، اما مکان لو نرود!',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'راهنمای بازی',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
}

class _TimerPainter extends CustomPainter {
  final double progress;

  _TimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paintBg = Paint()
      ..color = AppTheme.cardBgLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final paintProgress = Paint()
      ..shader = const SweepGradient(
        startAngle: -1.57,
        endAngle: 4.71,
        colors: [
          AppTheme.pink,
          AppTheme.pinkPurple,
          AppTheme.primaryPurple,
          AppTheme.lightPurple,
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paintBg);

    final dashPaint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashCount = 60;
    const dashAngle = (2 * 3.14159) / dashCount;
    const dashLength = 6.0;
    final innerR = radius - 20;
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

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
