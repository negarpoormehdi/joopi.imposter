import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/game_state.dart';

class _PaintStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool erasing;

  const _PaintStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.erasing,
  });
}

class PaintGameplayScreen extends StatefulWidget {
  final GameState gameState;
  const PaintGameplayScreen({super.key, required this.gameState});

  @override
  State<PaintGameplayScreen> createState() => _PaintGameplayScreenState();
}

class _PaintGameplayScreenState extends State<PaintGameplayScreen> {
  int _roundNumber = 1;
  final int _totalRounds = 3;
  late int _timeSeconds;
  late int _totalTimeSeconds;
  bool _isPaused = false;
  bool _isEnded = false;
  late final List<GamePlayer> _players;
  int _currentPainterIndex = 0;
  bool _showSubject = false;

  final List<_PaintStroke> _strokes = [];
  final List<_PaintStroke> _redoStack = [];
  _PaintStroke? _currentStroke;
  Color _selectedColor = const Color(0xFF13101C);
  double _strokeWidth = 4.0;
  int _brushSizeIndex = 1;
  bool _erasing = false;

  static const List<double> _brushSizes = [2.0, 4.0, 9.0];
  static const List<Color> _palette = [
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFA855F7),
    Color(0xFF13101C),
  ];

  @override
  void initState() {
    super.initState();
    _players = widget.gameState.players;
    _totalTimeSeconds = widget.gameState.roundTimeSeconds;
    _timeSeconds = _totalTimeSeconds;
  }

  String get _formattedTime {
    final mins = _timeSeconds ~/ 60;
    final secs = _timeSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}'
        .toFa;
  }

  void _togglePause() => setState(() => _isPaused = !_isPaused);

  void _addOneMinute() {
    setState(() {
      _timeSeconds += 60;
      if (_totalTimeSeconds < _timeSeconds) _totalTimeSeconds = _timeSeconds;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.add(_strokes.removeLast());
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _strokes.add(_redoStack.removeLast());
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _currentStroke = null;
    });
  }

  void _setBrushSize(int i) {
    setState(() {
      _brushSizeIndex = i;
      _strokeWidth = _brushSizes[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPainter = _players[_currentPainterIndex % _players.length];
    final isSpy = currentPainter.isSpy;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 18),
              _buildTimeControlBar(),
              const SizedBox(height: 18),
              _buildPainterSubjectBar(currentPainter, isSpy),
              const SizedBox(height: 18),
              _buildUnifiedPaintSection(),
              const SizedBox(height: 18),
              _buildPaletteRow(),
              const SizedBox(height: 20),
              _buildTipCard(),
              const SizedBox(height: 20),
              _buildEndRoundButton(),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: 'حدس فوری مکان توسط جاسوس؟ اینجا بزنید ',
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: 6),
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                    const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Text(
                            'مود نقاشی جاسوس  ',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          Icon(
                            Icons.palette_outlined,
                            color: AppTheme.pinkPurple,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'راند ${_roundNumber.toFa} • نوبت نقاشی سارا',
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

  Widget _buildTimeControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            GestureDetector(
              onTap: _togglePause,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B4FC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: const Color(0xFF2D124D),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addOneMinute,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: AppTheme.textPrimary,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+۱ دقیقه'.toFa,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'زمان باقی‌مانده کشیدن',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Color(0xFFB4ACC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedTime,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: _timeSeconds < 60
                        ? AppTheme.red
                        : AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgPurple.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Color(0xFFD6B4FC),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainterSubjectBar(GamePlayer painter, bool isSpy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.32),
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.45),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _showSubject = !_showSubject),
                  behavior: HitTestBehavior.opaque,
                  child: const Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_off_outlined,
                          color: AppTheme.textPrimary,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'دیدن سوژه',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    const Text(
                      'نقاش فعلی:',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.brush, color: AppTheme.orange, size: 16),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgPurple.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppTheme.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            painter.name,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '(حدس: همه)',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.green,
                            ),
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
      ),
    );
  }

  Widget _buildThicknessDot(int index, double dotSize) {
    final isSelected = _brushSizeIndex == index;
    return GestureDetector(
      onTap: () => _setBrushSize(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFFD6B4FC), width: 2)
              : null,
        ),
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? const Color(0xFFD6B4FC)
                : Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedPaintSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          children: [
            // Top Toolbar Row
            Row(
              textDirection: TextDirection.ltr,
              children: [
                // Clear / Delete
                GestureDetector(
                  onTap: _clearCanvas,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F1924),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFF87171),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Thickness selector pill
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBgLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildThicknessDot(2, 9.5),
                      const SizedBox(width: 8),
                      _buildThicknessDot(1, 6.0),
                      const SizedBox(width: 8),
                      _buildThicknessDot(0, 3.5),
                      const SizedBox(width: 8),
                      const Text(
                        'ضخامت:',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Color(0xFFA19BAE),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Undo
                GestureDetector(
                  onTap: _undo,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgLight,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.undo_rounded,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Vertical divider
                Container(
                  width: 1,
                  height: 18,
                  color: const Color(0xFF38314A),
                ),
                const SizedBox(width: 6),
                // Eraser (block / prohibition icon)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _erasing = !_erasing;
                      if (_erasing) {
                        _selectedColor = const Color(0xFFF5F6FA);
                      } else {
                        _selectedColor = _palette.last;
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _erasing
                          ? const Color(0xFFD6B4FC)
                          : AppTheme.cardBgLight,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.block_rounded,
                      color: _erasing
                          ? const Color(0xFF2D124D)
                          : Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Pencil (active)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _erasing = false;
                      if (_selectedColor == const Color(0xFFF5F6FA)) {
                        _selectedColor = _palette.last;
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: !_erasing
                          ? const Color(0xFFD6B4FC)
                          : AppTheme.cardBgLight,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: !_erasing
                          ? const Color(0xFF2D124D)
                          : Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // White Canvas
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GestureDetector(
                onPanStart: (d) {
                  _redoStack.clear();
                  setState(() {
                    _currentStroke = _PaintStroke(
                      points: [d.localPosition],
                      color: _erasing
                          ? const Color(0xFFF5F6FA)
                          : _selectedColor,
                      strokeWidth: _strokeWidth,
                      erasing: _erasing,
                    );
                  });
                },
                onPanUpdate: (d) {
                  if (_currentStroke == null) return;
                  setState(() {
                    _currentStroke = _PaintStroke(
                      points: [..._currentStroke!.points, d.localPosition],
                      color: _currentStroke!.color,
                      strokeWidth: _currentStroke!.strokeWidth,
                      erasing: _currentStroke!.erasing,
                    );
                  });
                },
                onPanEnd: (_) {
                  if (_currentStroke == null) return;
                  setState(() {
                    _strokes.add(_currentStroke!);
                    _currentStroke = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  height: 330,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: CustomPaint(
                          painter: _CanvasPainter(
                            strokes: _strokes,
                            current: _currentStroke,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE2E4ED),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'بوم نقاشی تعاملی',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: Color(0xFF6B5AA2),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Bottom Palette Row
            Row(
              textDirection: TextDirection.ltr,
              children: [
                // "بیشتر +"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Color(0xFFA19BAE),
                      size: 15,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'بیشتر',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Color(0xFFA19BAE),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Colors
                ...List.generate(_palette.length, (i) {
                  final c = _palette[i];
                  final isSelected = _selectedColor == c && !_erasing;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _erasing = false;
                      _selectedColor = c;
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 7),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 2,
                                )
                              : null,
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                            border: i == _palette.length - 1 && !isSelected
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteRow() {
    return const SizedBox.shrink();
  }

  Widget _buildTipCard() {
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
                    const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            color: AppTheme.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'قانون نقاشی:',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'نوشتن متن یا عدد روی بوم ممنوع است! فقط با خطوط و اشکال منظور را برسانید تا جاسوس متوجه کلمه نشود.',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.7,
                      ),
                      textDirection: TextDirection.rtl,
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

  Widget _buildEndRoundButton() {
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
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.25),
              AppTheme.cardBg,
              AppTheme.cardBg,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.18),
              blurRadius: 28,
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
                  color: AppTheme.bgPurple.withValues(alpha: 0.6),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.6),
                  ),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppTheme.lightPurple,
                  size: 30,
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
                            '🎁 پایان نقاشی و حدس زدن',
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
                      'شروع رای‌گیری برای پیدا کردن جاسوس',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
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
                  color: AppTheme.bgPurple.withValues(alpha: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.55),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<_PaintStroke> strokes;
  final _PaintStroke? current;

  _CanvasPainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      _drawStroke(canvas, s);
    }
    if (current != null) _drawStroke(canvas, current!);
  }

  void _drawStroke(Canvas canvas, _PaintStroke s) {
    if (s.points.isEmpty) return;
    final paint = Paint()
      ..color = s.erasing ? const Color(0xFFF5F5FA) : s.color
      ..strokeWidth = s.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.srcOver;

    if (s.points.length == 1) {
      final dotPaint = Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill
        ..strokeWidth = 1;
      canvas.drawCircle(s.points.first, s.strokeWidth / 2, dotPaint);
      return;
    }
    if (s.points.length == 2) {
      canvas.drawLine(s.points[0], s.points[1], paint);
      return;
    }
    final path = Path()..moveTo(s.points[0].dx, s.points[0].dy);
    for (int i = 1; i < s.points.length - 1; i++) {
      final p0 = s.points[i - 1];
      final p1 = s.points[i];
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }
    final pL = s.points.last;
    final pP = s.points[s.points.length - 2];
    final midX = (pP.dx + pL.dx) / 2;
    final midY = (pP.dy + pL.dy) / 2;
    path.quadraticBezierTo(pP.dx, pP.dy, midX, midY);
    path.lineTo(pL.dx, pL.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter old) =>
      old.strokes.length != strokes.length ||
      old.current?.points.length != current?.points.length;
}
