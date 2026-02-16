import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ListaChatsScreen extends StatefulWidget {
  final String username;
  final String password;

  const ListaChatsScreen({super.key, required this.username, required this.password});

  @override
  State<ListaChatsScreen> createState() => _ListaChatsScreenState();
}

class _ListaChatsScreenState extends State<ListaChatsScreen> {
  final ChatService _service = ChatService();
  List<dynamic> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarChats();
  }

  void _cargarChats() async {
    final res = await _service.getChatsActivos(widget.username, widget.password);
    if (mounted) setState(() { _chats = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mensajes (24h)"), backgroundColor: const Color(0xFF0033A0), foregroundColor: Colors.white),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _chats.isEmpty 
          ? const Center(child: Text("No tienes chats activos en las últimas 24h"))
          : ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final chat = _chats[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(chat['usuario_nombre'][0].toUpperCase()),
                  ),
                  title: Text(chat['usuario_nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(chat['ultimo_mensaje'], maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                      otroUsuarioId: chat['usuario_id'],
                      otroUsuarioNombre: chat['usuario_nombre'],
                      myUser: widget.username,
                      myPass: widget.password
                    )));
                  },
                );
              },
            ),
    );
  }
}