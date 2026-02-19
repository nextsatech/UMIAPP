import 'package:flutter/material.dart';
import '../models/objeto_modelo.dart';
import '../services/objetos_service.dart';
import '../screens/chat_screen.dart';

class TarjetaObjeto extends StatefulWidget {
  final ObjetoPerdido objeto;
  final String username;
  final String token;
  final ObjetosService servicio;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TarjetaObjeto({
    super.key,
    required this.objeto,
    required this.username,
    required this.token,
    required this.servicio,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<TarjetaObjeto> createState() => _TarjetaObjetoState();
}

class _TarjetaObjetoState extends State<TarjetaObjeto> {
  late bool _yaDioLike;
  late int _numLikes;
  late List<dynamic> _comentarios;

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

    bool exito = await widget.servicio.toggleLike(widget.objeto.id, widget.token);

    if (!exito) {
      if (mounted) {
        setState(() {
          _yaDioLike = !_yaDioLike;
          _numLikes += _yaDioLike ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al dar like. Revisa tu conexión.")),
        );
      }
    }
  }

  void _mostrarDialogoEditar() {
    final tituloCtrl = TextEditingController(text: widget.objeto.titulo ?? "");
    final descCtrl = TextEditingController(text: widget.objeto.descripcion);
    final ubicacionCtrl = TextEditingController(text: widget.objeto.ubicacion ?? "");
    
    String estadoActual = widget.objeto.estado;
    const opcionesValidas = ['PERDIDO', 'ENCONTRADO', 'ENTREGADO', 'N/A'];
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
                widget.token
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
              widget.objeto.id, texto, widget.token
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
                            token: widget.token,
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
      case 'NA': return "N/A";
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