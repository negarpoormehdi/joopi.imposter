import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/game_settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'جاسوس بازی',
      theme: AppTheme.darkTheme(),
      builder: (context, child) {
        final defaultTextStyle = DefaultTextStyle.of(context);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTextStyle(
            style: defaultTextStyle.style.copyWith(
              fontFamily: AppTheme.fontFamily,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const GameSettingsScreen(),
    );
  }
}
