import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/game_state.dart';
import 'gameplay_screen.dart';

class RoleDistributionFlowScreen extends StatefulWidget {
  final GameState gameState;

  const RoleDistributionFlowScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<RoleDistributionFlowScreen> createState() => _RoleDistributionFlowScreenState();
}

class _RoleDistributionFlowScreenState extends State<RoleDistributionFlowScreen>
    with TickerProviderStateMixin {
  int _currentPlayerIndex = 0;
  int _revealedPlayers = 0;

  bool _isRevealing = false;

  double _dragOffset = 0.0;
  static const double _revealThreshold = -120.0;

  bool _showNextButton = false;

  GamePlayer get _current => widget.gameState.players[_currentPlayerIndex];
  int get _total => widget.gameState.playerCount;

  void _finishRevealAndAdvance() {
    setState(() {
      _revealedPlayers++;
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
      setState(() {
        _showNextButton = true;
      });
    }
  }

  void _goToNextPlayer() {
    setState(() {
      _currentPlayerIndex++;
      _isRevealing = false;
      _dragOffset = 0.0;
      _showNextButton = false;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (_showNextButton) return;
    if (_isRevealing) {
      if (d.globalPosition.dy > 0) {
        setState(() {
          _dragOffset = d.localPosition.dy.clamp(-600, 0.0) * 0.0;
        });
      }
      return;
    }
    setState(() {
      _dragOffset = d.localPosition.dy.clamp(-600, 0.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    if (_showNextButton) return;
    if (!_isRevealing && _dragOffset <= _revealThreshold) {
      setState(() {
        _isRevealing = true;
        _dragOffset = -280.0;
      });
      _finishRevealAndAdvance();
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  void _onTapReveal() {
    if (_showNextButton) return;
    if (!_isRevealing) {
      setState(() {
        _isRevealing = true;
        _dragOffset = -280.0;
      });
      _finishRevealAndAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildRoleCard(),
                    const SizedBox(height: 36),
                    _buildBottomActionButton(),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: Text(
                          'تغییر نقش تست (جاسوس / شهروند)',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
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
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: List.generate(_total > 8 ? 8 : _total, (index) {
              final activeIdx = _total > 8
                  ? ((_currentPlayerIndex / _total) * 8).floor()
                  : _currentPlayerIndex;
              final isActive = index == activeIdx;
              final isPassed = index < activeIdx;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryPurple
                      : isPassed
                          ? AppTheme.primaryPurple.withOpacity(0.5)
                          : AppTheme.cardBgLight,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    final playerColor = Color(_current.color.value);
    final name = _current.name;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _onTapReveal,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(48),
                    top: Radius.circular(12),
                  ),
                  color: AppTheme.cardBg,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                top: _dragOffset,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(48),
                      top: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.darkPurple,
                        AppTheme.pinkPurple.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.45),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),
                        _buildPlayerName(name, playerColor),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        if (_isRevealing)
                          _buildRoleContent()
                        else
                          _buildPullIndicator(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        if (!_isRevealing)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _showNextButton
                                  ? 'نقش نمایش داده شد'
                                  : 'برای مشاهده به بالا بکشید یا روی کارت ضربه بزنید',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFEDE9FE),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerName(String name, Color playerColor) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
            border: Border.all(
              color: playerColor.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person_outline,
            color: playerColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildPullIndicator() {
    return Column(
      children: [
        Transform.rotate(
          angle: 0,
          child: Icon(
            Icons.keyboard_arrow_up,
            color: Color.lerp(
              const Color(0xFFDDD6FE),
              Colors.white,
              (-_dragOffset / 200).clamp(0.0, 1.0),
            )!,
            size: 92,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.35 + (-_dragOffset / 300).clamp(0.0, 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _current.isSpy
                  ? Colors.redAccent.withOpacity(0.6)
                  : AppTheme.lightPurple.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _current.isSpy ? Icons.warning_amber : Icons.location_on,
                color: _current.isSpy ? Colors.red.shade200 : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                _current.isSpy ? 'شما جاسوس هستید' : 'مکان بازی:',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Container(
          constraints: const BoxConstraints(minWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Text(
            _current.role,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        if (!_current.isSpy) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFFE9D5FF),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سعی کنید با سوالات هوشمندانه جاسوس را پیدا کنید',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8FF),
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
        ] else ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Color(0xFFFECACA),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'هیچکسی نباید متوجه شود شما مکان را نمی‌دانید',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFEE2E2),
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
      ],
    );
  }

  Widget _buildBottomActionButton() {
    return GestureDetector(
      onTap: _showNextButton ? _goToNextPlayer : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.cardBg,
              _showNextButton ? AppTheme.cardBgLight : AppTheme.cardBgLight.withOpacity(0.7),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _showNextButton
                ? AppTheme.primaryPurple.withOpacity(0.55)
                : AppTheme.primaryPurple.withOpacity(0.25),
          ),
          boxShadow: _showNextButton
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.25),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _showNextButton ? 1.0 : 0.45,
          child: AbsorbPointer(
            absorbing: !_showNextButton,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _showNextButton
                          ? const [AppTheme.primaryPurple, AppTheme.lightPurple]
                          : [
                              AppTheme.cardBgLight,
                              AppTheme.cardBgLight,
                            ],
                    ),
                    boxShadow: _showNextButton
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: _showNextButton ? Colors.white : AppTheme.textMuted,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currentPlayerIndex + 1 >= _total
                            ? 'شروع بازی'
                            : 'نفر بعدی',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentPlayerIndex + 1 >= _total
                            ? 'همه نقش‌ها دیده شد • بریم سراغ بازی'
                            : 'گوشی رو بده به بازیکن بعدی',
                        style: const TextStyle(
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
                    color: (_showNextButton ? AppTheme.primaryPurple : AppTheme.textMuted)
                        .withOpacity(0.15),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color:
                        _showNextButton ? AppTheme.primaryPurple : AppTheme.textMuted,
                    size: 30,
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
