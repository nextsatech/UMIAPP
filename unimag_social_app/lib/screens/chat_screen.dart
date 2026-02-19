import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int otroUsuarioId;
  final String otroUsuarioNombre;
  final String myUser;
  final String token;

  const ChatScreen({
    super.key,
    required this.otroUsuarioId,
    required this.otroUsuarioNombre,
    required this.myUser,
    required this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _service = ChatService();
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<dynamic> _mensajes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _cargarMensajes());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _cargarMensajes() async {
    final nuevos = await _service.getMensajes(widget.otroUsuarioId, widget.token);
    if (mounted) {
      setState(() {
        _mensajes = nuevos;
      });
    }
  }

  void _enviar() async {
    if (_textCtrl.text.trim().isEmpty) return;
    String texto = _textCtrl.text;
    _textCtrl.clear();

    setState(() {
      _mensajes.add({'contenido': texto, 'es_mio': true, 'fecha': DateTime.now().toString()});
    });
    _scrollToBottom();

    await _service.enviarMensaje(widget.otroUsuarioId, texto, widget.token);
    _cargarMensajes(); 
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otroUsuarioNombre, style: const TextStyle(fontSize: 16)),
            const Text("Se borra en 24h ⏳", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esMio = msg['es_mio'];
                return Align(
                  alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: esMio ? const Color(0xFF0033A0) : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(esMio ? 16 : 0),
                        bottomRight: Radius.circular(esMio ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['contenido'],
                          style: TextStyle(color: esMio ? Colors.white : Colors.black87, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF6C00),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _enviar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}