import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String apiRoot = 'http://172.17.0.1:8000/api';

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
        final body = jsonDecode(response.body);
        return body['error'] ?? 'Error al enviar código';
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
        return {'success': false, 'message': response.body};
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
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Error desconocido'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  final _storage = const FlutterSecureStorage();

  Future<void> guardarSesion(String user, String pass) async {
    await _storage.write(key: 'username', value: user);
    await _storage.write(key: 'password', value: pass);
  }

  Future<Map<String, String>?> obtenerSesion() async {
    final user = await _storage.read(key: 'username');
    final pass = await _storage.read(key: 'password');
    
    if (user != null && pass != null) {
      return {'username': user, 'password': pass};
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

  Map<String, String> _getAuthHeader(String user, String pass) {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$user:$pass'))}';
    return {'authorization': basicAuth, 'Content-Type': 'application/json'};
  }

  Future<bool> actualizarPerfil(String nuevoNombre, String user, String pass) async {
    try {
      final response = await http.put(
        Uri.parse('$urlAuth/perfil/actualizar/'),
        headers: _getAuthHeader(user, pass),
        body: jsonEncode({'username': nuevoNombre}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> cambiarPassword(String oldPass, String newPass, String user) async {
    try {
      final response = await http.post(
        Uri.parse('$urlAuth/password/cambiar/'),
        headers: _getAuthHeader(user, oldPass), 
        body: jsonEncode({'old_password': oldPass, 'new_password': newPass}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> eliminarCuenta(String user, String pass) async {
    try {
      final response = await http.delete(
        Uri.parse('$urlAuth/cuenta/eliminar/'),
        headers: _getAuthHeader(user, pass),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> enviarSugerencia(String mensaje, String user, String pass) async {
    try {
      final response = await http.post(
        Uri.parse('$urlAuth/sugerencia/'), 
        headers: _getAuthHeader(user, pass),
        body: jsonEncode({'mensaje': mensaje}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}
