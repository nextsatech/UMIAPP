class ObjetoPerdido {
  final int id;
  final int usuarioId;
  final String titulo;
  final String descripcion;
  final List<String> fotosUrls; 
  final String ubicacion;
  final String estado; // 'PERDIDO', 'ENCONTRADO'
  final String fecha;
  final String usuarioNombre;
  final String usuarioCarrera;
  final bool esDueno;
  final int numLikes;
  final bool yaDioLike;
  final List<dynamic> comentarios;

  ObjetoPerdido({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.fotosUrls,
    required this.ubicacion,
    required this.estado,
    required this.fecha,
    required this.usuarioNombre,
    required this.usuarioCarrera,
    required this.esDueno,
    required this.numLikes,
    required this.yaDioLike,
    required this.comentarios,
  });

  
  factory ObjetoPerdido.fromJson(Map<String, dynamic> json) {
    var listaFotos = json['fotos'] as List? ?? [];
    List<String> urls = listaFotos.map((f) => f['imagen'].toString()).toList();
    return ObjetoPerdido(
      id: json['id'],
      usuarioId: json['usuario_id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fotosUrls: urls, 
      ubicacion: json['ubicacion'] ?? 'Desconocida',
      estado: json['estado'] ?? 'PERDIDO',
      fecha: json['fecha_publicacion'] ?? '',
      usuarioNombre: json['usuario_nombre'] ?? 'Anónimo',
      usuarioCarrera: json['usuario_carrera'] ?? 'Administrativo',
      esDueno: json['es_dueno'] ?? false,
      numLikes: json['num_likes'] ?? 0,
      yaDioLike: json['ya_dio_like'] ?? false,
      comentarios: json['comentarios'] ?? [],
    );
  }
}