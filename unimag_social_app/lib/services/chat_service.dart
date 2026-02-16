import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  
  final String apiRoot = 'http://172.17.0.1:8000/api';

  Map<String, String> _getAuthHeader(String user, String pass) {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$user:$pass'))}';
    return {'authorization': basicAuth, 'Content-Type': 'application/json'};
  }

  Future<List<dynamic>> getMensajes(int otroUsuarioId, String user, String pass) async {
    final url = Uri.parse('$apiRoot/chat/$otroUsuarioId/');
    try {
      final response = await http.get(url, headers: _getAuthHeader(user, pass));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Enviar mensaje
  Future<bool> enviarMensaje(int otroUsuarioId, String contenido, String user, String pass) async {
    final url = Uri.parse('$apiRoot/chat/$otroUsuarioId/');
    try {
      final response = await http.post(
        url,
        headers: _getAuthHeader(user, pass),
        body: jsonEncode({'contenido': contenido}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getChatsActivos(String user, String pass) async {
    final url = Uri.parse('$apiRoot/mis-chats/');
    try {
      final response = await http.get(url, headers: _getAuthHeader(user, pass));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}