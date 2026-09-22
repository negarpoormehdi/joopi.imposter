import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/game_state.dart';
import 'gameplay_screen.dart';

class RoleDistributionFlowScreen extends StatefulWidget {
  final GameState gameState;

  const RoleDistributionFlowScreen({super.key, required this.gameState});

  @override
  State<RoleDistributionFlowScreen> createState() =>
      _RoleDistributionFlowScreenState();
}

class _RoleDistributionFlowScreenState extends State<RoleDistributionFlowScreen>
    with SingleTickerProviderStateMixin {
  int _currentPlayerIndex = 0;

  bool _isRevealed = false;
  double _dragOffset = 0.0;

  late final AnimationController _snapController;
  late Animation<double> _snapAnimation;

  bool _showNextButton = false;

  GamePlayer get _current => widget.gameState.players[_currentPlayerIndex];
  int get _total => widget.gameState.playerCount;

  static const double _revealThreshold = -260;
  static const double _revealOffset = -420;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _snapAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.addListener(() {
      if (_snapController.isAnimating) {
        setState(() => _dragOffset = _snapAnimation.value);
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _animateSnap(double from, double to, {VoidCallback? onCompleted}) {
    _snapAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.reset();
    _snapController.forward().then((_) {
      if (mounted) {
        setState(() => _dragOffset = to);
        onCompleted?.call();
      }
    });
  }

  void _finishRevealAndAdvance() {
    setState(() {
      _isRevealed = true;
    });
    if (_currentPlayerIndex + 1 >= _total) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameplayScreen(gameState: widget.gameState),
          ),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showNextButton = true);
      });
    }
  }

  void _goToNextPlayer() {
    setState(() {
      _currentPlayerIndex++;
      _isRevealed = false;
      _dragOffset = 0.0;
      _showNextButton = false;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (_showNextButton) return;
    if (_isRevealed) return;
    final delta = d.primaryDelta ?? 0;
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(-700, 0.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    if (_showNextButton) return;
    if (_isRevealed) return;
    if (_dragOffset <= _revealThreshold) {
      _animateSnap(
        _dragOffset,
        _revealOffset,
        onCompleted: () {
          if (mounted) _finishRevealAndAdvance();
        },
      );
    } else {
      _animateSnap(_dragOffset, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            _buildRevealedBackground(size),
            _buildPurpleSheet(size),
            _buildBottomFixedSection(),
            _buildTopBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final totalDots = _total > 8 ? 8 : _total;
    final activeIdx = _total > 8
        ? ((_currentPlayerIndex / _total) * totalDots).floor()
        : _currentPlayerIndex;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Row(
                  children: List.generate(totalDots, (index) {
                    final isActive = index == activeIdx;
                    final isPassed = index < activeIdx;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryPurple
                            : isPassed
                            ? AppTheme.primaryPurple.withOpacity(0.55)
                            : AppTheme.cardBgLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'بازیکن  '),
                          TextSpan(
                            text: '${(_currentPlayerIndex + 1).toFa}',
                            style: const TextStyle(
                              color: AppTheme.lightPurple,
                              fontSize: 22,
                            ),
                          ),
                          const TextSpan(text: '  از  '),
                          TextSpan(
                            text: '${_total.toFa}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.person_outline,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevealedBackground(Size size) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          const Spacer(flex: 62),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildRoleDisplayBox(),
          ),
          const Spacer(flex: 38),
        ],
      ),
    );
  }

  Widget _buildRoleDisplayBox() {
    final revealed = _isRevealed || _dragOffset < -60;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: revealed ? 1.0 : 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _current.isSpy
                    ? Colors.redAccent.withOpacity(0.55)
                    : AppTheme.lightPurple.withOpacity(0.55),
                width: 1.4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _current.isSpy
                      ? Icons.warning_amber_rounded
                      : Icons.location_on_rounded,
                  color: _current.isSpy
                      ? Colors.red.shade200
                      : AppTheme.lightPurple,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _current.isSpy ? 'شما جاسوس هستید' : 'مکان بازی:',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            constraints: const BoxConstraints(minWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              _current.role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _current.isSpy
                    ? Colors.red.withOpacity(0.12)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _current.isSpy
                      ? Colors.red.withOpacity(0.28)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _current.isSpy ? Icons.shield_outlined : Icons.info_outline,
                    color: _current.isSpy
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE9D5FF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _current.isSpy
                          ? 'هیچکسی نباید متوجه شود شما مکان را نمی دانید'
                          : 'سعی کنید با سوالات هوشمندانه جاسوس را پیدا کنید',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: _current.isSpy
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFF3E8FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurpleSheet(Size size) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 220,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF7C3AED),
                  AppTheme.primaryPurple,
                  AppTheme.darkPurple,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(48),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 22),
                Text(
                  _current.name,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 28),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppTheme.lightPurple.withOpacity(0.9),
                  size: 76,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.lightPurple.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 22),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'برای مشاهده به بالا بکشید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Color(0xFFEDE9FE),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const Spacer(flex: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFixedSection() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Column(
            children: [
              _buildNextButton(),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'تغییر نقش تست (جاسوس / شهروند)',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final active = _showNextButton;
    return GestureDetector(
      onTap: active ? _goToNextPlayer : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active
                ? AppTheme.primaryPurple.withOpacity(0.6)
                : AppTheme.primaryPurple.withOpacity(0.22),
            width: 1.2,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: active ? 1.0 : 0.45,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? AppTheme.primaryPurple.withOpacity(0.15)
                        : AppTheme.cardBgLight,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: active ? AppTheme.lightPurple : AppTheme.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPlayerIndex + 1 >= _total
                            ? 'شروع بازی'
                            : 'نفر بعدی',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: active
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentPlayerIndex + 1 >= _total
                            ? 'همه نقش ها دیده شد • بریم سراغ بازی'
                            : 'گوشی رو بده به بازیکن بعدی',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: active
                              ? AppTheme.textSecondary
                              : AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? AppTheme.primaryPurple
                        : AppTheme.cardBgLight,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: active ? Colors.white : AppTheme.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
