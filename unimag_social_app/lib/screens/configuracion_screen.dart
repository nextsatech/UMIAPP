import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  final String username;
  final String password;

  const ConfiguracionScreen({super.key, required this.username, required this.password});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final AuthService _authService = AuthService();
  late String _currentUsername;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
  }

  // --- DIÁLOGO EDITAR PERFIL ---
  void _mostrarEditarPerfil() {
    final controller = TextEditingController(text: _currentUsername);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar Nombre de Usuario"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nuevo nombre"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
  if (controller.text.isEmpty) return;
  
 
  final exito = await _authService.actualizarPerfil(controller.text, widget.username, widget.password);
  
  if (exito) {
    
    await _authService.guardarSesion(controller.text, widget.password);
    
    if (mounted) {
      Navigator.pop(ctx); 
      
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nombre actualizado. Por favor inicia sesión nuevamente."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        )
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, 
        );
      });
    }
  } else {
    _msg("Error: Nombre en uso o inválido");
  }
},
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  
  void _mostrarCambiarPass() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar Contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña Actual")),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Nueva Contraseña")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (oldCtrl.text != widget.password) {
                _msg("La contraseña actual no coincide");
                return;
              }
              final exito = await _authService.cambiarPassword(widget.password, newCtrl.text, widget.username);
              if (exito) {
                
                await _authService.guardarSesion(widget.username, newCtrl.text);
                if (mounted) {
                   Navigator.pop(ctx); 
                   
                   _cerrarSesionTotal(); 
                }
                _msg("Contraseña cambiada. Por favor inicia sesión de nuevo.");
              } else {
                _msg("Error al cambiar contraseña");
              }
            },
            child: const Text("Cambiar"),
          )
        ],
      ),
    );
  }

  // --- ELIMINAR CUENTA ---
  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar cuenta?", style: TextStyle(color: Colors.red)),
        content: const Text("Esta acción borrará todos tus datos, publicaciones y fotos. No se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final exito = await _authService.eliminarCuenta(widget.username, widget.password);
              if (exito) {
                _cerrarSesionTotal();
              } else {
                _msg("No se pudo eliminar la cuenta");
              }
            },
            child: const Text("ELIMINAR DEFINITIVAMENTE"),
          )
        ],
      ),
    );
  }

  void _cerrarSesionTotal() async {
    await _authService.cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: ListView(
        children: [
          
          _SeccionTitulo("PERFIL"),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF0033A0)),
            title: const Text("Nombre de Usuario"),
            subtitle: Text(_currentUsername),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: _mostrarEditarPerfil,
          ),
          
          const Divider(),

          
          _SeccionTitulo("SEGURIDAD"),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange),
            title: const Text("Cambiar Contraseña"),
            subtitle: const Text("Protege tu cuenta"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _mostrarCambiarPass,
          ),
          const Divider(),

          
          _SeccionTitulo("INFORMACIÓN"),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text("Versión de la App"),
            subtitle: const Text("1.0.0 (Beta)"),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.grey),
            title: const Text("Soporte y Ayuda"),
            onTap: () => _msg("Contacta a umimag2026@gmail.com"),
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            title: const Text("Buzón de Sugerencias"),
            subtitle: const Text("Ayúdanos a mejorar"),
            onTap: _mostrarDialogoSugerencia, 
          ),
          const Divider(),

          
          _SeccionTitulo("ZONA DE PELIGRO", color: Colors.red),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Eliminar Cuenta", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _confirmarEliminar,
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSugerencia() {
    final textCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.lightbulb, color: Colors.amber), SizedBox(width: 10), Text("Sugerencias")]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Qué podemos mejorar? Tu opinión llega directo a los desarrolladores."),
            const SizedBox(height: 10),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Escribe tu idea aquí...",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0033A0), foregroundColor: Colors.white),
            onPressed: () async {
              if (textCtrl.text.isEmpty) return;
              
              Navigator.pop(ctx); // Cerramos rápido
              _msg("Enviando...");
              
              final exito = await _authService.enviarSugerencia(textCtrl.text, widget.username, widget.password);
              
              if (exito) {
                _msg("¡Gracias! Hemos recibido tu sugerencia 📧");
              } else {
                _msg("Error al enviar. Intenta más tarde.");
              }
            },
            child: const Text("Enviar"),
          )
        ],
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final Color color;
  const _SeccionTitulo(this.titulo, {this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        titulo,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}