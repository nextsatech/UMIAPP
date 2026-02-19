import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiRoot = 'https://umiapp.pythonanywhere.com/api';

  Map<String, String> _getAuthHeader(String token) {
    return {
      'Authorization': 'Token $token', 
      'Content-Type': 'application/json'
    };
  }

  Future<List<dynamic>> getMensajes(int otroUsuarioId, String token) async {
    final url = Uri.parse('$apiRoot/chat/$otroUsuarioId/');
    try {
      final response = await http.get(url, headers: _getAuthHeader(token));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> enviarMensaje(int otroUsuarioId, String contenido, String token) async {
    final url = Uri.parse('$apiRoot/chat/$otroUsuarioId/');
    try {
      final response = await http.post(
        url,
        headers: _getAuthHeader(token),
        body: jsonEncode({'contenido': contenido}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getChatsActivos(String token) async {
    final url = Uri.parse('$apiRoot/mis-chats/');
    try {
      final response = await http.get(url, headers: _getAuthHeader(token));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}