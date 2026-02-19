import 'package:flutter/material.dart';
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
            brightness: Brightness.light,
            primaryColor: const Color(0xFF0033A0),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0033A0),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF0033A0),
            
            scaffoldBackgroundColor: const Color(0xFF121212), 
            cardColor: const Color(0xFF1E1E1E), 
            
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0033A0),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E), 
              primary: const Color(0xFF6B8CE6), 
              secondary: const Color(0xFFFF6C00), 
            ),
            useMaterial3: true,

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2C2C2C), 
              hintStyle: const TextStyle(color: Colors.grey),
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIconColor: const Color(0xFF6B8CE6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF6B8CE6), width: 1.5),
              ),
            ),

            
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E), 
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}