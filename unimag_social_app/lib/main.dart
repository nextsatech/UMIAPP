import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; 
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'UMi',
          debugShowCheckedModeBanner: false,
          
          themeMode: mode, 
          
          theme: ThemeData(
            primaryColor: const Color(0xFF0033A0),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0033A0)),
            useMaterial3: true,
          ),
          
        
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFF0033A0),
            scaffoldBackgroundColor: const Color(0xFF121212), 
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0033A0),
              secondary: Color(0xFFFF6C00),
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}