import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String apiRoot = 'https://umiapp.pythonanywhere.com/api';
  final _storage = const FlutterSecureStorage();

  String get urlAuth => '$apiRoot/auth';

  Future<String?> solicitarCodigo(String email) async {
    final url = Uri.parse('$urlAuth/solicitar-codigo/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        try {
          final body = jsonDecode(response.body);
          return body['error'] ?? 'Error al enviar código';
        } catch (_) {
          return 'Error en el servidor';
        }
      }
    } catch (e) {
      return 'Error de conexión';
    }
  }

  Future<Map<String, dynamic>> registrarUsuario(
      String email, String codigo, String password, String carrera) async {
    final url = Uri.parse('$urlAuth/registro/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'codigo': codigo,
          'password': password,
          'carrera': carrera
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final body = jsonDecode(response.body);
          return {'success': false, 'message': body['error'] ?? 'Error al registrar'};
        } catch (_) {
          return {'success': false, 'message': 'Error en el servidor'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$urlAuth/login/'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['error'] ?? 'Error desconocido'};
        } catch (_) {
          return {'success': false, 'message': 'Error en el servidor'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<void> guardarSesion(String token, String username) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'username', value: username);
  }

  Future<Map<String, String>?> obtenerSesion() async {
    final token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');
    
    if (token != null && username != null) {
      return {'token': token, 'username': username};
    }
    return null; 
  }

  Future<void> cerrarSesion() async {
    await _storage.deleteAll();
  }

  Future<bool> solicitarRecuperacion(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$urlAuth/recuperar/'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }

  Future<Map<String, dynamic>> confirmarRecuperacion(String email, String codigo, String nuevaPass) async {
    try {
      final response = await http.post(
        Uri.parse('$urlAuth/recuperar-confirmar/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'codigo': codigo, 
          'password': nuevaPass
        }),
      );
      return jsonDecode(response.body); 
    } catch (e) { 
      return {'error': 'Error de conexión'}; 
    }
  }

  Map<String, String> getAuthHeader(String token) {
    return {'Authorization': 'Token $token', 'Content-Type': 'application/json'};
  }

  Future<bool> actualizarPerfil(String nuevoNombre, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$urlAuth/perfil/actualizar/'),
        headers: getAuthHeader(token),
        body: jsonEncode({'username': nuevoNombre}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> cambiarPassword(String oldPass, String newPass, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$urlAuth/password/cambiar/'),
        headers: getAuthHeader(token), 
        body: jsonEncode({'old_password': oldPass, 'new_password': newPass}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> eliminarCuenta(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$urlAuth/cuenta/eliminar/'),
        headers: getAuthHeader(token),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> enviarSugerencia(String mensaje, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$urlAuth/sugerencia/'), 
        headers: getAuthHeader(token),
        body: jsonEncode({'mensaje': mensaje}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}