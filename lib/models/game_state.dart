import 'dart:math';

class GamePlayer {
  final String name;
  final String role;
  final bool isSpy;
  final ColorAssigned color;

  const GamePlayer({
    required this.name,
    required this.role,
    required this.isSpy,
    required this.color,
  });
}

class ColorAssigned {
  final int value;
  const ColorAssigned(this.value);
}

class GameState {
  final List<GamePlayer> players;
  final int spyCount;
  final int roundTimeMinutes;
  final String location;
  final List<String> activeCategories;
  final bool paintCanvasModeEnabled;
  final bool showLocationListForSpy;
  final bool soundEnabled;

  const GameState({
    required this.players,
    required this.spyCount,
    required this.roundTimeMinutes,
    required this.location,
    required this.activeCategories,
    required this.paintCanvasModeEnabled,
    required this.showLocationListForSpy,
    required this.soundEnabled,
  });

  int get playerCount => players.length;
  int get roundTimeSeconds => roundTimeMinutes * 60;
}

class GameStateBuilder {
  List<String> playerNames;
  int spyCount;
  int roundTimeMinutes;
  Set<String> activeCategories;
  bool paintCanvasModeEnabled;
  bool showLocationListForSpy;
  bool soundEnabled;

  GameStateBuilder({
    required this.playerNames,
    required this.spyCount,
    required this.roundTimeMinutes,
    required this.activeCategories,
    required this.paintCanvasModeEnabled,
    required this.showLocationListForSpy,
    required this.soundEnabled,
  });

  static const _playerColors = [
    ColorAssigned(0xFFA78BFA),
    ColorAssigned(0xFFEC4899),
    ColorAssigned(0xFF3B82F6),
    ColorAssigned(0xFFC026D3),
    ColorAssigned(0xFFEF4444),
    ColorAssigned(0xFF10B981),
    ColorAssigned(0xFFF59E0B),
    ColorAssigned(0xFF06B6D4),
    ColorAssigned(0xFF8B5CF6),
    ColorAssigned(0xFFF472B6),
  ];

  static const _locationsMap = {
    'مکان‌ها': [
      'رستوران لوکس',
      'پارک تفریحی',
      'فرودگاه',
      'هتل پنج ستاره',
      'بیمارستان',
      'موزه هنر',
      'کتابخانه بزرگ',
      'باشگاه ورزشی',
      'سینما',
      'کافه محبوب',
      'شهرداری',
      'دانشگاه',
      'سوپرمارکت',
      'ایستگاه مترو',
      'فرودگاه',
      'ساحل دریا',
      'کوهستان',
      'باغ موزه',
      'تئاتر شهر',
      'استخر شنا',
    ],
    'مشاغل': [
      'پزشک جراح',
      'معلم مدرسه',
      'مهندس معماری',
      'هنرمند نقاش',
      'راننده تاکسی',
      'آشپز سرآشپز',
      'کاربر شبکه',
      'موسیقیدان',
      'وکیل دادگستری',
      'روزنامه‌نگار',
      'پلیس',
      'آتش نشان',
      'خلبان هواپیما',
      'مهندس نرم‌افزار',
      'پزشک دامپزشک',
    ],
    'اشیاء': [
      'موبایل هوشمند',
      'لپ‌تاپ',
      'ساعت مچی گران‌بها',
      'دوربین عکاسی',
      'گیتار الکتریک',
      'ماکروفر',
      'ماشین لباسشویی',
      'یخچال فریزر',
      'لپ‌تاپ گیمینگ',
      'هندزفری بلوتوث',
    ],
    'حیوانات': [
      'شیر آفریقا',
      'فیل بزرگ',
      'خرس قطبی',
      'حیوان غریب طاووس',
      'گورخر جنگل',
      'دلفین اقیانوس',
      'کنگورو استرالیا',
      'کاپیبارا',
      'پاندا سرخ',
      'دریای مردابی',
    ],
  };

  static const _defaultLocations = [
    'رستوران لوکس',
    'فرودگاه',
    'هتل پنج ستاره',
    'کافه محبوب',
    'بیمارستان',
    'دانشگاه',
    'سوپرمارکت',
    'سینما',
    'موزه هنر',
    'پارک تفریحی',
  ];

  GameState build() {
    final names = List<String>.from(playerNames);
    final random = Random();

    final shuffledIndices = List<int>.generate(names.length, (i) => i)
      ..shuffle(random);

    final spyIndices = shuffledIndices.take(spyCount).toSet();

    final categories = activeCategories.isEmpty
        ? {'مکان‌ها'}
        : activeCategories;
    final allLocations = <String>[];
    for (final c in categories) {
      allLocations.addAll(_locationsMap[c] ?? _defaultLocations);
    }
    final locationPool = allLocations.isEmpty
        ? _defaultLocations
        : allLocations;
    final selectedLocation = locationPool[random.nextInt(locationPool.length)];

    final players = List<GamePlayer>.generate(names.length, (i) {
      final isSpy = spyIndices.contains(i);
      return GamePlayer(
        name: names[i],
        role: isSpy ? 'جاسوس' : selectedLocation,
        isSpy: isSpy,
        color: _playerColors[i % _playerColors.length],
      );
    });

    return GameState(
      players: players,
      spyCount: spyCount,
      roundTimeMinutes: roundTimeMinutes,
      location: selectedLocation,
      activeCategories: categories.toList(),
      paintCanvasModeEnabled: paintCanvasModeEnabled,
      showLocationListForSpy: showLocationListForSpy,
      soundEnabled: soundEnabled,
    );
  }
}
