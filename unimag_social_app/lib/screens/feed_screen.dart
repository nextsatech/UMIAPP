import 'package:flutter/material.dart';
import '../models/objeto_modelo.dart';
import '../services/objetos_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'publicar_screen.dart';
import '../main.dart';
import 'foro_screen.dart';
import 'configuracion_screen.dart';
import 'chat_screen.dart';
import 'lista_chats_screen.dart';
import '../services/notification_service.dart';

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
La plataforma no asume responsabilidad por daños, perjuicios o consecuencias derivadas del uso de la información compartida dentro de la aplicación.
Cada usuario es responsable de evaluar la información que consume o comparte.

Uso Responsable
El anonimato proporcionado por la plataforma tiene como finalidad facilitar la libre expresión y la participación comunitaria, por lo que se espera que los usuarios actúen con respeto, prudencia y responsabilidad.

El uso de la aplicación implica la aceptación de estas condiciones.
""";

class FeedScreen extends StatefulWidget {
  final String username;
  final String password;
  

  const FeedScreen({
    super.key, 
    required this.username, 
    required this.password
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ObjetosService _servicio = ObjetosService();
  late Future<List<ObjetoPerdido>> _listaObjetos;
  final NotificationService _notifService = NotificationService(); 

  @override
  void initState() {
    super.initState();
    _recargarFeed();
    
    
    _notifService.init().then((_) {
      _notifService.startPolling(widget.username, widget.password);
    });
  }

  @override
  void dispose() {
    _notifService.stopPolling(); 
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _recargarFeed();
  }

  void _recargarFeed() {
    setState(() {
      _listaObjetos = _servicio.getObjetos(widget.username, widget.password);
    });
  }
  
  void _cerrarSesion() async {
    final authService = AuthService();
    await authService.cerrarSesion();

    if (!context.mounted) return;
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
                widget.username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Estudiante Unimagdalena"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.username.isNotEmpty ? widget.username[0].toUpperCase() : "U",
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
                            username: widget.username,
                            password: widget.password,
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
                             username: widget.username, 
                             password: widget.password
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
              return _TarjetaObjeto(
                objeto: obj,
                username: widget.username,
                password: widget.password,
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
                    await _servicio.borrarObjeto(obj.id, widget.username, widget.password);
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
              builder: (context) => PublicarScreen(
                username: widget.username, 
                password: widget.password,
              ),
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
              username: widget.username,
              password: widget.password,
            ),
          ),
        );
      },
      dense: true,
    );
  }
}

class _TarjetaObjeto extends StatefulWidget {
  final ObjetoPerdido objeto;
  final String username;
  final String password;
  final ObjetosService servicio;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TarjetaObjeto({
    required this.objeto,
    required this.username,
    required this.password,
    required this.servicio,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_TarjetaObjeto> createState() => _TarjetaObjetoState();
}

class _TarjetaObjetoState extends State<_TarjetaObjeto> {
  late bool _yaDioLike;
  late int _numLikes;
  late List<dynamic> _comentarios;
  final ObjetosService _servicio = ObjetosService();

  @override
  void initState() {
    super.initState();
    _yaDioLike = widget.objeto.yaDioLike;
    _numLikes = widget.objeto.numLikes;
    _comentarios = List.from(widget.objeto.comentarios);
  }

  void _toggleLike() async {
    setState(() {
      _yaDioLike = !_yaDioLike;
      _numLikes += _yaDioLike ? 1 : -1;
    });

    await widget.servicio.toggleLike(widget.objeto.id, widget.username, widget.password);
  }

  void _mostrarDialogoEditar() {
    final tituloCtrl = TextEditingController(text: widget.objeto.titulo ?? "");
    final descCtrl = TextEditingController(text: widget.objeto.descripcion);
    final ubicacionCtrl = TextEditingController(text: widget.objeto.ubicacion ?? "");
    
    String estadoActual = widget.objeto.estado;
    const opcionesValidas = ['PERDIDO', 'ENCONTRADO', 'ENTREGADO', 'NA'];
    if (!opcionesValidas.contains(estadoActual)) {
      estadoActual = 'N/A';
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Editar Publicación", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: tituloCtrl,
                decoration: InputDecoration(
                  labelText: "Título",
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
                )
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descCtrl, 
                maxLines: 3, 
                decoration: InputDecoration(
                  labelText: "Descripción",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
                )
              ),
              const SizedBox(height: 15),
              TextField(
                controller: ubicacionCtrl,
                decoration: InputDecoration(
                  labelText: "Ubicación",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
                )
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: estadoActual,
                decoration: InputDecoration(
                  labelText: "Estado del objeto",
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                items: const [
                  DropdownMenuItem(value: 'N/A', child: Text("N/A - Ninguna")),
                  DropdownMenuItem(value: 'PERDIDO', child: Text("Buscando")),
                  DropdownMenuItem(value: 'ENCONTRADO', child: Text("Encontrado")),
                  DropdownMenuItem(value: 'ENTREGADO', child: Text("Entregado al dueño")),
                ],
                onChanged: (val) => estadoActual = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0033A0), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              final data = {
                'titulo': tituloCtrl.text,
                'descripcion': descCtrl.text,
                'ubicacion': ubicacionCtrl.text,
                'estado': estadoActual,
              };

              Navigator.pop(ctx);

              bool exito = await widget.servicio.editarObjeto(
                widget.objeto.id, 
                data, 
                widget.username, 
                widget.password
              );

              if (exito) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Publicación actualizada")));
                widget.onEdit(); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al editar")));
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  void _mostrarComentarios() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: _HojaComentarios(
          comentarios: _comentarios,
          onEnviar: (texto) async {
            bool exito = await widget.servicio.enviarComentario(
              widget.objeto.id, texto, widget.username, widget.password
            );
            if (exito) {
              setState(() {
                _comentarios.add({
                  'usuario_nombre': widget.username,
                  'texto': texto,
                });
              });
              if (mounted) Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(widget.objeto.usuarioNombre),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.objeto.usuarioNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${_getEstadoIcono(widget.objeto.estado)} • ${widget.objeto.ubicacion}",
                        style: TextStyle(
                          color: Colors.grey[500], 
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                if (!widget.objeto.esDueno)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otroUsuarioId: widget.objeto.usuarioId,
                            otroUsuarioNombre: widget.objeto.usuarioNombre,
                            myUser: widget.username,
                            myPass: widget.password,
                          )
                        )
                      );
                    },
                  ),

                if (widget.objeto.esDueno)
                  PopupMenuButton(
                    icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    onSelected: (value) {
                      if (value == 'editar') _mostrarDialogoEditar();
                      if (value == 'borrar') widget.onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Editar")])),
                      const PopupMenuItem(value: 'borrar', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Borrar", style: TextStyle(color: Colors.red))])),
                    ],
                  ),
              ],
            ),
          ),

          if (widget.objeto.titulo != null && widget.objeto.titulo!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                widget.objeto.titulo!,
                style: TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.w800, 
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          
          if (widget.objeto.descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                widget.objeto.descripcion,
                style: TextStyle(
                  fontSize: 15, 
                  color: isDark ? Colors.white70 : const Color(0xFF333333),
                  height: 1.4 
                ),
              ),
            ),
          
          if (widget.objeto.fotosUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(0), 
              child: GridFotos(imagenes: widget.objeto.fotosUrls),
            ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: _toggleLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _yaDioLike ? const Color(0xFFFFEBEE) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _yaDioLike ? Icons.favorite : Icons.favorite_border_rounded,
                          color: _yaDioLike ? const Color(0xFFFF2D55) : Colors.grey[600],
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$_numLikes",
                          style: TextStyle(
                            color: _yaDioLike ? const Color(0xFFFF2D55) : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),

                InkWell(
                  onTap: _mostrarComentarios,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: Colors.grey[600], size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "${_comentarios.length}",
                          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoIcono(String estado) {
    switch (estado) {
      case 'ENCONTRADO': return "ENCONTRADO";
      case 'ENTREGADO': return "ENTREGADO";
      case 'N/A': return "N/A";
      default: return "🔍";
    }
  }

  Widget _buildAvatar(String nombre) {
    final colorBase = Colors.primaries[nombre.length % Colors.primaries.length];
    
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: colorBase.withOpacity(0.2), 
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2), 
      ),
      child: Center(
        child: Text(
          nombre.isNotEmpty ? nombre[0].toUpperCase() : "?",
          style: TextStyle(
            color: colorBase, 
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
      ),
    );
  }
}

class GridFotos extends StatelessWidget {
  final List<String> imagenes;

  const GridFotos({super.key, required this.imagenes});

  void _abrirGaleria(BuildContext context, int indice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisorFotos(imagenes: imagenes, indiceInicial: indice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagenes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _abrirGaleria(context, 0),
              child: Image.network(imagenes[0], fit: BoxFit.cover, height: double.infinity),
            ),
          ),
          
          if (imagenes.length > 1) ...[
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _abrirGaleria(context, 1),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.network(imagenes[1], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  
                  if (imagenes.length > 2) ...[
                    const SizedBox(height: 2),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _abrirGaleria(context, 2),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(imagenes[2], fit: BoxFit.cover),
                            
                            if (imagenes.length > 3)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text(
                                    "+${imagenes.length - 3}",
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 24, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class VisorFotos extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;

  const VisorFotos({
    super.key, 
    required this.imagenes, 
    this.indiceInicial = 0
  });

  @override
  State<VisorFotos> createState() => _VisorFotosState();
}

class _VisorFotosState extends State<VisorFotos> {
  late PageController _pageController;
  late int _indiceActual;

  @override
  void initState() {
    super.initState();
    _indiceActual = widget.indiceInicial;
    _pageController = PageController(initialPage: widget.indiceInicial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagenes.length,
            onPageChanged: (index) {
              setState(() => _indiceActual = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.imagenes[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (c, child, progress) {
                      if (progress == null) return child;
                      return const CircularProgressIndicator(color: Colors.white);
                    },
                  ),
                ),
              );
            },
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "${_indiceActual + 1} / ${widget.imagenes.length}",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HojaComentarios extends StatefulWidget {
  final List<dynamic> comentarios;
  final Function(String) onEnviar;

  const _HojaComentarios({required this.comentarios, required this.onEnviar});

  @override
  State<_HojaComentarios> createState() => _HojaComentariosState();
}

class _HojaComentariosState extends State<_HojaComentarios> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Comentarios", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            Expanded(
              child: widget.comentarios.isEmpty
                  ? const Center(child: Text("Sin comentarios"))
                  : ListView.builder(
                      itemCount: widget.comentarios.length,
                      itemBuilder: (c, i) {
                        final com = widget.comentarios[i];
                        final nombre = com is Map ? com['usuario_nombre'] : com['usuario_nombre'];
                        final texto = com is Map ? com['texto'] : com['texto'];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(nombre ?? 'Anónimo', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(texto ?? ''),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un comentario...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      widget.onEnviar(_controller.text);
                      _controller.clear();
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}