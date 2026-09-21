import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TopicsScreen extends StatefulWidget {
  final Set<String> initialSelection;

  const TopicsScreen({
    super.key,
    this.initialSelection = const {'مکان‌ها', 'مشاغل'},
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late Set<String> _activeCategories;

  final List<Map<String, dynamic>> _categoryCards = [
    {
      'key': 'مکان‌ها',
      'title': 'اماکن و سفر',
      'icon': Icons.place,
      'items': '۳۲ مکان',
      'badge': 'کلاسیک',
      'badgeColor': AppTheme.primaryPurple,
      'categoryIconColor': AppTheme.primaryPurple,
    },
    {
      'key': 'مشاغل',
      'title': 'مشاغل مرموز',
      'icon': Icons.search,
      'items': '۲۴ شغل',
      'badge': 'مهیج',
      'badgeColor': AppTheme.orange,
      'categoryIconColor': AppTheme.primaryPurple,
    },
    {
      'key': 'اشیاء',
      'title': 'سینما و فانتزی',
      'icon': Icons.movie,
      'items': '۱۸ کلمه',
      'badge': 'تخیلی',
      'badgeColor': AppTheme.blue,
      'categoryIconColor': AppTheme.blue,
    },
    {
      'key': 'حیوانات',
      'title': 'غذا و دورهمی',
      'icon': Icons.local_cafe_outlined,
      'items': '۲۲ کلمه',
      'badge': 'خوشمزه',
      'badgeColor': AppTheme.pink,
      'categoryIconColor': AppTheme.pinkPurple,
    },
    {
      'key2': 'علم',
      'title': 'علم و تکنولوژی',
      'icon': Icons.memory,
      'items': '۱۹ کلمه',
      'badge': 'مدرن',
      'badgeColor': AppTheme.green,
      'categoryIconColor': AppTheme.primaryPurple,
    },
    {
      'key2': 'جنایی',
      'title': 'مافیا و گنگستری',
      'icon': Icons.umbrella_outlined,
      'items': '۱۶ کلمه',
      'badge': 'جنایی',
      'badgeColor': AppTheme.darkPurple,
      'categoryIconColor': AppTheme.primaryPurple,
    },
  ];

  int get _selectedCount => _categoryCards.where((c) => _isSelected(c)).length;

  bool _isSelected(Map<String, dynamic> card) {
    final key = card['key'] as String?;
    if (key == null) return false;
    return _activeCategories.contains(key);
  }

  void _toggle(Map<String, dynamic> card) {
    final key = card['key'] as String?;
    if (key == null) return;
    setState(() {
      if (_activeCategories.contains(key)) {
        _activeCategories.remove(key);
      } else {
        _activeCategories.add(key);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _activeCategories = Set<String>.from(widget.initialSelection);
  }

  void _confirmAndBack() {
    Navigator.of(context).pop<Set<String>>(_activeCategories);
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
                title: 'موضوعات بازی',
                subtitle: 'دسته‌های دلخواهت رو انتخاب کن',
                onBack: () =>
                    Navigator.of(context).pop<Set<String>>(_activeCategories),
                navIcon: Icons.arrow_forward_ios,
              ),
              _buildTopBar(),
              const SizedBox(height: 8),
              _buildFeaturedBanner(),
              const SizedBox(height: 20),
              _buildSectionTitles(),
              const SizedBox(height: 12),
              ..._buildTopicGrids(),
              const SizedBox(height: 20),
              BottomActionButton(
                title: 'تایید و ادامه بازی',
                subtitle:
                    '${(_selectedCount * 20).toFa}+ کلمه فعال • ${_selectedCount.toFa} دسته‌بندی فعال',
                leftIcon: Icons.group,
                rightIcon: Icons.arrow_back,
                leftColor: AppTheme.lightPurple,
                rightColor: AppTheme.lightPurple,
                showLeftGlow: false,
                showRightGlow: true,
                onTap: _confirmAndBack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.textMuted, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'جستجوی موضوعات یا کلمات....',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _toggleAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.green.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Text(
                    'انتخاب همه',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.green,
                      shape: BoxShape.circle,
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

  void _toggleAll() {
    setState(() {
      final allKeys = _categoryCards
          .map((c) => c['key'] as String?)
          .whereType<String>();
      final allSelected = allKeys.every((k) => _activeCategories.contains(k));
      if (allSelected) {
        _activeCategories.clear();
      } else {
        _activeCategories = Set<String>.from(allKeys);
      }
    });
  }

  Widget _buildFeaturedBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.darkPurple,
            AppTheme.pinkPurple,
            AppTheme.primaryPurple,
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.draw_outlined, color: Colors.white, size: 30),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(Icons.edit, color: Colors.amber, size: 22),
                ),
              ],
            ),
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
                      'کلمات اختصاصی شما',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '۴ کلمه',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'لوکیشن‌ها و شوخی‌های شخصی اکیپ',
                  style: TextStyle(
                    color: Colors.white70,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppTheme.primaryPurple, size: 20),
                const SizedBox(width: 6),
                Text(
                  'مدیریت',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'برای فعال سازی لمس کنید',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
          Text(
            'دسته‌بندی‌ها (کارت‌های بازی)',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopicGrids() {
    final list = <Widget>[];
    for (var i = 0; i < _categoryCards.length; i += 2) {
      final rightCard = _categoryCards[i];
      final leftCard = (i + 1 < _categoryCards.length)
          ? _categoryCards[i + 1]
          : null;
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: leftCard != null
                    ? _buildTopicCard(leftCard)
                    : const SizedBox.shrink(),
              ),
              if (leftCard != null) const SizedBox(width: 12),
              Expanded(child: _buildTopicCard(rightCard)),
            ],
          ),
        ),
      );
    }
    return list;
  }

  Widget _buildTopicCard(Map<String, dynamic> item) {
    final selectable = item['key'] != null;
    final selected = selectable && _isSelected(item);
    return GestureDetector(
      onTap: () => setState(() => _toggle(item)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selectable
                ? (selected
                      ? AppTheme.primaryPurple.withOpacity(0.8)
                      : AppTheme.cardBgLight)
                : AppTheme.cardBgLight.withOpacity(0.6),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item['categoryIconColor'] as Color,
                        (item['categoryIconColor'] as Color).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (item['categoryIconColor'] as Color).withOpacity(
                          0.4,
                        ),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryPurple
                        : AppTheme.cardBgLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? Colors.white
                          : AppTheme.textMuted.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item['title'] as String,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppTheme.cardBgLight),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (item['badgeColor'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item['title'] == 'سینما و فانتزی')
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.stars,
                            color: Color(0xFFFCD34D),
                            size: 14,
                          ),
                        ),
                      if (item['title'] == 'مشاغل مرموز')
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.whatshot,
                            color: AppTheme.orange,
                            size: 14,
                          ),
                        ),
                      Text(
                        item['badge'] as String,
                        style: TextStyle(
                          color: item['badgeColor'] as Color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item['items'] as String,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
