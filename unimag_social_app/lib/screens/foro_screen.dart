import 'package:flutter/material.dart';
import '../services/objetos_service.dart';
import 'chat_screen.dart';

const List<Map<String, String>> CARRERAS_UNIMAG = [
  {'val': 'TODAS', 'label': 'Todas las carreras / General'},
  {'val': 'MEDICINA', 'label': 'Medicina'},
  {'val': 'ENFERMERIA', 'label': 'Enfermería'},
  {'val': 'ODONTOLOGIA', 'label': 'Odontología'},
  {'val': 'PSICOLOGIA', 'label': 'Psicología'},
  {'val': 'ADMIN_EMPRESAS', 'label': 'Administración de Empresas'},
  {'val': 'ADMIN_TURISMO', 'label': 'Adm. Empresas Turísticas'},
  {'val': 'NEGOCIOS', 'label': 'Negocios Internacionales'},
  {'val': 'CONTADURIA', 'label': 'Contaduría Pública'},
  {'val': 'ECONOMIA', 'label': 'Economía'},
  {'val': 'DERECHO', 'label': 'Derecho'},
  {'val': 'ANTROPOLOGIA', 'label': 'Antropología'},
  {'val': 'CINE', 'label': 'Cine y Audiovisuales'},
  {'val': 'BIOLOGIA', 'label': 'Biología'},
  {'val': 'ING_SISTEMAS', 'label': 'Ingeniería de Sistemas'},
  {'val': 'ING_CIVIL', 'label': 'Ingeniería Civil'},
  {'val': 'ING_INDUSTRIAL', 'label': 'Ingeniería Industrial'},
  {'val': 'ING_ELECTRONICA', 'label': 'Ingeniería Electrónica'},
  {'val': 'ING_AMBIENTAL', 'label': 'Ing. Ambiental y Sanitaria'},
  {'val': 'ING_AGRONOMICA', 'label': 'Ingeniería Agronómica'},
  {'val': 'ING_PESQUERA', 'label': 'Ingeniería Pesquera'},
  {'val': 'LIC_LENGUAS', 'label': 'Lic. en Lenguas Extranjeras'},
];

class ForoScreen extends StatefulWidget {
  final String tipoForo;
  final String username;
  final String token;

  const ForoScreen({
    super.key,
    required this.tipoForo,
    required this.username,
    required this.token,
  });

  @override
  State<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends State<ForoScreen> {
  final ObjetosService _servicio = ObjetosService();
  late Future<List<dynamic>> _posts;
  String? _filtroCarrera = 'TODAS';

  Color get _colorPrimario {
    switch (widget.tipoForo) {
      case 'CONFESIONES': return Colors.purple.shade900;
      case 'EVENTOS': return const Color(0xFFFF6C00);
      case 'DUDAS': return Colors.teal;
      default: return const Color(0xFF0033A0);
    }
  }

  String get _titulo {
    switch (widget.tipoForo) {
      case 'CONFESIONES': return "Confesiones";
      case 'DUDAS': return "Dudas Académicas";
      case 'EVENTOS': return "Eventos y Fiestas";
      default: return "Foro General";
    }
  }

  bool get _esConfesion => widget.tipoForo == 'CONFESIONES';

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _posts = _servicio.getPostsForo(widget.tipoForo, _filtroCarrera, widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool darkTheme = _esConfesion;

    return Theme(
      data: darkTheme ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: darkTheme ? const Color(0xFF121212) : Colors.grey[100],
        appBar: AppBar(
          title: Text(_titulo),
          backgroundColor: _colorPrimario,
          foregroundColor: Colors.white,
          actions: [
             IconButton(icon: const Icon(Icons.refresh), onPressed: _recargar),
          ],
        ),
        body: Column(
          children: [
            if (widget.tipoForo == 'DUDAS')
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _filtroCarrera,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Filtrar por Carrera",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                  ),
                  items: CARRERAS_UNIMAG.map((c) {
                    return DropdownMenuItem(
                      value: c['val'],
                      child: Text(
                        c['label']!,
                        overflow: TextOverflow.ellipsis
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _filtroCarrera = val);
                    _recargar();
                  },
                ),
              ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _posts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: _colorPrimario));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _esConfesion ? Icons.visibility_off : Icons.forum_outlined,
                            size: 60, color: Colors.grey
                          ),
                          const SizedBox(height: 10),
                          const Text("Sé el primero en publicar algo.", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data![index];
                      return _TarjetaForo(
                        post: post,
                        esConfesion: _esConfesion,
                        colorTema: _colorPrimario,
                        username: widget.username,
                        token: widget.token,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _colorPrimario,
          onPressed: () async {
            final resultado = await showDialog(
              context: context,
              builder: (_) => _DialogoPublicar(
                tipoForo: widget.tipoForo,
                username: widget.username,
                token: widget.token,
              ),
            );
            if (resultado == true) _recargar();
          },
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }
}

class _DialogoPublicar extends StatefulWidget {
  final String tipoForo;
  final String username;
  final String token;
  
  const _DialogoPublicar({
    required this.tipoForo, 
    required this.username, 
    required this.token
  });

  @override
  State<_DialogoPublicar> createState() => _DialogoPublicarState();
}

class _DialogoPublicarState extends State<_DialogoPublicar> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _tagCtrl = TextEditingController();
  final ObjetosService _service = ObjetosService();
  
  bool _esAnonimo = false;
  bool _enviando = false; 
  String? _carreraSeleccionada;

  @override
  void initState() {
    super.initState();
    if (widget.tipoForo == 'CONFESIONES') {
      _esAnonimo = true;
    }
    if (widget.tipoForo == 'DUDAS') {
      _carreraSeleccionada = 'TODAS'; 
    }
  }

  void _publicar() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _enviando = true); 

    String? carreraEnviar;
    if (widget.tipoForo == 'DUDAS') {
      carreraEnviar = (_carreraSeleccionada == 'TODAS') ? null : _carreraSeleccionada;
    }

    final data = {
      'tipo': widget.tipoForo,
      'contenido': _controller.text,
      'es_anonimo': _esAnonimo,
      'carrera_filtro': carreraEnviar, 
      'tag': _tagCtrl.text.isNotEmpty ? _tagCtrl.text : null
    };

    final exito = await _service.crearPostForo(data, widget.token);

    if (mounted) {
      setState(() => _enviando = false); 
      
      if (exito) {
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al publicar"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Publicar en ${widget.tipoForo}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "¿Qué quieres preguntar o compartir?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            
            if (widget.tipoForo != 'CONFESIONES')
              Row(
                children: [
                  Checkbox(
                    value: _esAnonimo, 
                    onChanged: (val) => setState(() => _esAnonimo = val!)
                  ),
                  const Text("Publicar como anónimo"),
                ],
              ),

            if (widget.tipoForo == 'DUDAS') ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _carreraSeleccionada,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Dirigido a carrera (Opcional)",
                  prefixIcon: Icon(Icons.school, color: Colors.teal),
                  border: OutlineInputBorder(),
                ),
                items: CARRERAS_UNIMAG.map((c) => DropdownMenuItem(
                  value: c['val'], 
                  child: Text(c['label']!, overflow: TextOverflow.ellipsis)
                )).toList(),
                onChanged: (val) => setState(() => _carreraSeleccionada = val),
              ),
            ],

            if (widget.tipoForo != 'CONFESIONES') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _tagCtrl,
                decoration: const InputDecoration(
                  labelText: "Hashtag",
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder()
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.pop(context), 
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0033A0), foregroundColor: Colors.white),
          onPressed: _enviando ? null : _publicar, 
          child: _enviando 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Publicar"),
        ),
      ],
    );
  }
}

class _TarjetaForo extends StatefulWidget {
  final dynamic post;
  final bool esConfesion;
  final Color colorTema;
  final String username;
  final String token;

  const _TarjetaForo({
    required this.post, 
    required this.esConfesion, 
    required this.colorTema,
    required this.username,
    required this.token,
  });

  @override
  State<_TarjetaForo> createState() => _TarjetaForoState();
}

class _TarjetaForoState extends State<_TarjetaForo> {
  late bool _yaDioLike;
  late int _numLikes;
  final ObjetosService _servicio = ObjetosService();

  @override
  void initState() {
    super.initState();
    _yaDioLike = widget.post['ya_dio_like'] ?? false;
    _numLikes = widget.post['num_likes'] ?? 0;
  }

  void _darLike() async {
    setState(() {
      _yaDioLike = !_yaDioLike;
      _numLikes += _yaDioLike ? 1 : -1;
    });

    bool exito = await _servicio.toggleLikeForo(
      widget.post['id'], 
      widget.token
    );

    if (!exito) {
      if (mounted) {
        setState(() {
          _yaDioLike = !_yaDioLike;
          _numLikes += _yaDioLike ? 1 : -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String subtitulo = "";
    if (widget.post['carrera_filtro'] != null && widget.post['carrera_filtro'].toString().isNotEmpty) {
      final carreraItem = CARRERAS_UNIMAG.firstWhere(
        (e) => e['val'] == widget.post['carrera_filtro'], 
        orElse: () => {'label': widget.post['carrera_filtro']}
      );
      subtitulo = "Para: ${carreraItem['label']}";
    } else if (widget.post['usuario_carrera'] != null) {
      subtitulo = widget.post['usuario_carrera'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.esConfesion ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.esConfesion ? Colors.purple.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
        border: widget.esConfesion ? Border.all(color: Colors.purple.withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
        
              CircleAvatar(
                backgroundColor: widget.esConfesion ? Colors.grey[800] : widget.colorTema.withOpacity(0.1),
                child: Text(
                  widget.esConfesion ? "?" : (widget.post['usuario_nombre'].isNotEmpty ? widget.post['usuario_nombre'][0].toUpperCase() : "U"),
                  style: TextStyle(
                    color: widget.esConfesion ? Colors.white : widget.colorTema, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post['usuario_nombre'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.esConfesion ? Colors.white : Colors.black87
                      ),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis, 
                    ),
                    if (subtitulo.isNotEmpty)
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.esConfesion ? Colors.grey[400] : Colors.grey[600]
                        ),
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              if (!widget.esConfesion && widget.post['usuario_nombre'] != widget.username)
                IconButton(
                  constraints: const BoxConstraints(), 
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blue),
                  onPressed: () {
                     if (widget.post['usuario_id'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error ID")));
                        return;
                     }
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otroUsuarioId: widget.post['usuario_id'],
                            otroUsuarioNombre: widget.post['usuario_nombre'],
                            myUser: widget.username,
                            token: widget.token,
                          )
                        )
                      );
                  },
                ),

              if (widget.post['tag'] != null && widget.post['tag'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 4, top: 8), 
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.esConfesion ? Colors.purpleAccent.withOpacity(0.2) : widget.colorTema.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "#${widget.post['tag']}",
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.esConfesion ? Colors.purpleAccent : widget.colorTema,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.post['contenido'],
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: widget.esConfesion ? Colors.grey[200] : Colors.black87
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: _darLike,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        _yaDioLike ? Icons.favorite : Icons.favorite_border, 
                        size: 22, 
                        color: _yaDioLike 
                          ? (widget.esConfesion ? Colors.purpleAccent : Colors.red) 
                          : (widget.esConfesion ? Colors.grey : Colors.grey[600])
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$_numLikes",
                        style: TextStyle(
                          color: widget.esConfesion ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.post['fecha'].toString().substring(0, 10),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            ],
          )
        ],
      ),
    );
  }
}