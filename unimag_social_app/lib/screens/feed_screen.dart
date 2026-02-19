import 'package:flutter/material.dart';
import '../models/objeto_modelo.dart';
import '../services/objetos_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'publicar_screen.dart';
import '../main.dart';
import 'foro_screen.dart';
import 'configuracion_screen.dart';
import 'lista_chats_screen.dart';
import '../services/notification_service.dart';
import '../widgets/tarjeta_objeto.dart';

const String TEXTO_POLITICAS = """
Objetivo de la Aplicación
La aplicación tiene como propósito ofrecer un espacio digital de interacción para la comunidad estudiantil, permitiendo la publicación de contenido, participación en foros, intercambio de información y expresión de ideas dentro de un entorno basado en el anonimato.

La plataforma busca fomentar la comunicación, la colaboración y la participación social entre los usuarios, sin exigir la exposición de la identidad personal.

Anonimato y Manejo de Información Personal
La aplicación funciona bajo un esquema de anonimato, por lo que los usuarios son responsables del contenido que decidan compartir de manera voluntaria.

El uso de la plataforma implica que cada usuario reconoce y acepta que:
La publicación de datos personales propios o de terceros se realiza bajo su única responsabilidad.
La plataforma no se hace responsable por la divulgación de información sensible, privada o confidencial que sea publicada por los usuarios.
Se recomienda evitar compartir datos que permitan la identificación directa o indirecta de personas, salvo en situaciones de necesidad legítima o urgencia.
La responsabilidad sobre la veracidad, pertinencia y consecuencias de la información publicada recae exclusivamente en el usuario que la comparte.

Contenido No Permitido
Con el fin de mantener un entorno seguro y respetuoso, no está permitido publicar contenido que incluya:
Amenazas, intimidaciones o incitación a la violencia.
Acoso, hostigamiento o persecución hacia otras personas.
Contenido pornográfico o sexual explícito.
Material ilegal o que vulnere derechos fundamentales.
Discurso de odio, discriminación o contenido ofensivo grave.
Suplantación de identidad.
Publicaciones que promuevan actividades ilícitas.

La plataforma se reserva el derecho de eliminar contenido que incumpla estas normas y de restringir el acceso a usuarios que realicen un uso indebido.

Limitación de Responsabilidad
La aplicación actúa únicamente como un medio tecnológico de publicación e interacción entre usuarios. En consecuencia:
No se garantiza la veracidad, exactitud o confiabilidad del contenido publicado por los usuarios.
La plataforma no se hace responsable por la daños, perjuicios o consecuencias derivadas del uso de la información compartida dentro de la aplicación.
Cada usuario es responsable de evaluar la información que consume o comparte.

Uso Responsable
El anonimato proporcionado por la plataforma tiene como finalidad facilitar la libre expresión y la participación comunitaria, por lo que se espera que los usuarios actúen con respeto, prudencia y responsabilidad.

El uso de la aplicación implica la aceptación de estas condiciones.
""";

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ObjetosService _servicio = ObjetosService();
  Future<List<ObjetoPerdido>>? _listaObjetos;
  final NotificationService _notifService = NotificationService(); 
  
  String _username = '';
  String _token = '';
  bool _cargandoSesion = true;

  @override
  void initState() {
    super.initState();
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    final authService = AuthService();
    final sesion = await authService.obtenerSesion();
    
    if (sesion != null && sesion['token'] != null) {
      setState(() {
        _username = sesion['username']!;
        _token = sesion['token']!;
        _cargandoSesion = false;
      });
      _recargarFeed();
      _notifService.init().then((_) {
        _notifService.startPolling(_token); 
      });
    } else {
      _cerrarSesion();
    }
  }

  @override
  void dispose() {
    _notifService.stopPolling(); 
    super.dispose();
  }

  void _recargarFeed() {
    if (_token.isNotEmpty) {
      setState(() {
        _listaObjetos = _servicio.getObjetos(_token);
      });
    }
  }
  
  void _cerrarSesion() async {
    final authService = AuthService();
    await authService.cerrarSesion();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _mostrarPoliticas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Políticas de Privacidad y Uso"),
        content: const SingleChildScrollView(
          child: Text(TEXTO_POLITICAS, style: TextStyle(fontSize: 14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoSesion) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: const Text(
          "UMi", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0033A0), 
        elevation: 0, 
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _recargarFeed,
            tooltip: "Recargar",
          ),
          const SizedBox(width: 10),
        ],
      ),
      
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0033A0),
              ),
              accountName: Text(
                _username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Estudiante Unimagdalena"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _username.isNotEmpty ? _username[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 30, color: Color(0xFF0033A0), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_rounded, color: Color(0xFF0033A0)),
                    title: const Text("Inicio"),
                    onTap: () => Navigator.pop(context), 
                  ),

                  ListTile(
                    leading: const Icon(Icons.chat_bubble_rounded, color: Colors.blueAccent),
                    title: const Text("Mis Mensajes"),
                    subtitle: const Text("Chats activos (24h)"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListaChatsScreen(
                            username: _username,
                            token: _token,
                          )
                        )
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.storefront_rounded, color: Colors.orange),
                    title: const Text("Marketplace / Ventas"),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Próximamente: Sección de Ventas"))
                      );
                    },
                  ),
                  
                  ExpansionTile(
                    leading: const Icon(Icons.forum_rounded, color: Colors.teal),
                    title: const Text("Foros de Discusión"),
                    children: [
                      _buildSubMenuForo("General", "GENERAL"),
                      _buildSubMenuForo("Dudas Académicas", "DUDAS"),
                      _buildSubMenuForo("Eventos & Fiestas", "EVENTOS"),
                      _buildSubMenuForo("Confesiones", "CONFESIONES"),
                    ],
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.settings_rounded, color: Colors.grey),
                    title: const Text("Configuración"),
                    onTap: () {
                       Navigator.pop(context);
                       Navigator.push(
                         context, 
                         MaterialPageRoute(
                           builder: (_) => ConfiguracionScreen(
                             username: _username, 
                             token: _token
                           )
                         )
                       );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.policy_rounded, color: Colors.grey),
                    title: const Text("Políticas de Privacidad"),
                    onTap: () {
                       Navigator.pop(context);
                       _mostrarPoliticas();
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), 
              child: Row(
                children: [
                  const Icon(Icons.dark_mode_rounded, color: Colors.purple), 
                  const SizedBox(width: 32), 
                  const Text("Modo Oscuro", style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(), 
                  Switch(
                    value: themeNotifier.value == ThemeMode.dark,
                    activeColor: const Color(0xFFFF6C00),
                    onChanged: (val) {
                      themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      setState(() {}); 
                    },
                  ),
                ],
              ),
            ),
                  
            const SizedBox(height: 10),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                "Cerrar Sesión", 
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
              ),
              onTap: _cerrarSesion,
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),

      body: FutureBuilder<List<ObjetoPerdido>>(
        future: _listaObjetos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Error de conexión", style: TextStyle(color: Colors.grey[600])),
                  TextButton(onPressed: _recargarFeed, child: const Text("Reintentar"))
                ],
              )
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No hay publicaciones aún", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                ],
              ),
            );
          }

          final objetos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: objetos.length,
            itemBuilder: (context, index) {
              final obj = objetos[index];
              return TarjetaObjeto(
                objeto: obj,
                username: _username,
                token: _token,
                servicio: _servicio,
                onDelete: () async {
                  final confirmar = await showDialog(
                    context: context, 
                    builder: (c) => AlertDialog(
                      title: const Text("¿Borrar publicación?"),
                      content: const Text("Esta acción no se puede deshacer."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Borrar", style: TextStyle(color: Colors.red))),
                      ],
                    )
                  );

                  if (confirmar == true) {
                    await _servicio.borrarObjeto(obj.id, _token);
                    _recargarFeed();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Objeto eliminado")));
                    }
                  }
                },
                onEdit: () {
                   _recargarFeed();
                },
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton.extended( 
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PublicarScreen(),
            ),
          );

          if (resultado == true) {
            _recargarFeed();
          }
        },
        backgroundColor: const Color(0xFFFF6C00),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Publicar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSubMenuForo(String titulo, String tipoCodigo) { 
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32),
      leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: Colors.grey),
      title: Text(titulo),
      onTap: () {
        Navigator.pop(context); 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForoScreen(
              tipoForo: tipoCodigo, 
              username: _username,
              token: _token,
            ),
          ),
        );
      },
      dense: true,
    );
  }
}