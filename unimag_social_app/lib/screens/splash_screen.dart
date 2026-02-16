import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'feed_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  void _verificarSesion() async {
    final authService = AuthService();
    final sesion = await authService.obtenerSesion();
    
    // Simular un tiempito de carga para que se vea el logo (opcional)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (sesion != null) {
      // ¡Hay sesión! Vamos directo al Feed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FeedScreen(
            username: sesion['username']!, 
            password: sesion['password']!
          ),
        ),
      );
    } else {
      // No hay sesión, vamos al Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0033A0), // Azul Unimag
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.school_rounded, size: 100, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text("Cargando...", style: TextStyle(color: Colors.white))
          ],
        ),
      ),
    );
  }
}