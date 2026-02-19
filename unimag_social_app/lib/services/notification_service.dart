import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  final String apiCheck = 'https://umiapp.pythonanywhere.com/api/notificaciones/check/';

  Timer? _timer;
  int _ultimoConteo = 0;

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
    
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void startPolling(String token) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _verificarMensajes(token);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<void> _verificarMensajes(String token) async {
    try {
      final response = await http.get(
        Uri.parse(apiCheck),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int nuevos = data['nuevos'];

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