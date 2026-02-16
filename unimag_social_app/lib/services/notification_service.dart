import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Para obtener la URL base

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService(); // Instancia para usar la misma URL
  
  // Usamos una IP hardcodeada o la del AuthService si la tienes pública
  final String apiCheck = 'http://192.168.1.15:8000/api/notificaciones/check/'; // AJUSTA TU IP AQUÍ

  Timer? _timer;
  int _ultimoConteo = 0;

  // Inicializar el plugin
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
    
    // Pedir permisos en Android 13+
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  // Iniciar el "Polling" (preguntar cada 10 segs)
  void startPolling(String user, String pass) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _verificarMensajes(user, pass);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<void> _verificarMensajes(String user, String pass) async {
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$user:$pass'))}';
      final response = await http.get(
        Uri.parse(apiCheck),
        headers: {'authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int nuevos = data['nuevos'];

        // Si hay mensajes nuevos y son más que antes, notificamos
        if (nuevos > 0 && nuevos > _ultimoConteo) {
          _mostrarNotificacion(nuevos);
        }
        
        _ultimoConteo = nuevos;
      }
    } catch (e) {
      print("Error check notificaciones: $e");
    }
  }

  Future<void> _mostrarNotificacion(int cantidad) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_mensajes', 
      'Mensajes Nuevos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, 
      '¡Tienes mensajes nuevos!', 
      'Tienes $cantidad mensaje(s) sin leer en el chat.', 
      details
    );
  }
}