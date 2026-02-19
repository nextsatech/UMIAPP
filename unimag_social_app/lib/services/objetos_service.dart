import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/objeto_modelo.dart';

class ObjetosService {
  final String apiRoot = 'https://umiapp.pythonanywhere.com/api';

  String get urlObjetos => '$apiRoot/objetos/';
  String get urlForo => '$apiRoot/foro/';

  Map<String, String> _getAuthHeader(String token) {
    return {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json'
    };
  }

  Future<List<ObjetoPerdido>> getObjetos(String token) async {
    try {
      final response = await http.get(
        Uri.parse(urlObjetos),
        headers: _getAuthHeader(token),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ObjetoPerdido.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> crearObjeto({
    required String titulo,
    required String descripcion,
    required String ubicacion,
    required String estado,
    required List<File> imagenes,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(urlObjetos));
      
      request.fields['titulo'] = titulo;
      request.fields['descripcion'] = descripcion;
      request.fields['ubicacion'] = ubicacion;
      request.fields['estado'] = estado;
      
      request.headers['Authorization'] = 'Token $token';

      if (imagenes.isNotEmpty) {
        for (var file in imagenes) {
          var foto = await http.MultipartFile.fromPath('imagenes_subidas', file.path);
          request.files.add(foto);
        }
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleLike(int id, String token) async {
    final url = Uri.parse('$urlObjetos$id/like/');
    try {
      final response = await http.post(
        url,
        headers: _getAuthHeader(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> borrarObjeto(int id, String token) async {
    final url = Uri.parse('$urlObjetos$id/');
    try {
      final response = await http.delete(
        url,
        headers: _getAuthHeader(token),
      );
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> enviarComentario(int id, String texto, String token) async {
    final url = Uri.parse('$urlObjetos$id/comentar/'); 
    try {
      final response = await http.post(
        url,
        headers: _getAuthHeader(token),
        body: jsonEncode({'texto': texto}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getPostsForo(String tipo, String? carrera, String token) async {
    String url = '$urlForo?tipo=$tipo';
    
    try {
      final response = await http.get(
        Uri.parse(url), 
        headers: _getAuthHeader(token)
      );
      
      if (response.statusCode == 200) {
        List<dynamic> todos = jsonDecode(utf8.decode(response.bodyBytes));
        
        return todos.where((p) {
          bool matchTipo = p['tipo'] == tipo;
          bool matchCarrera = true;
          if (tipo == 'DUDAS' && carrera != null && carrera != 'TODAS') {
            matchCarrera = p['carrera_filtro'] == carrera;
          }
          return matchTipo && matchCarrera;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> crearPostForo(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse(urlForo),
        headers: _getAuthHeader(token),
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleLikeForo(int idPost, String token) async {
    final url = Uri.parse('$urlForo$idPost/toggle_like/');
    
    try {
      final response = await http.post(
        url, 
        headers: _getAuthHeader(token)
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editarObjeto(int id, Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$urlObjetos$id/');
    
    try {
      final response = await http.patch(
        url,
        headers: _getAuthHeader(token),
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}