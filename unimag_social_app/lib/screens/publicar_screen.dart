import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/objetos_service.dart';

class PublicarScreen extends StatefulWidget {
  final String username;
  final String password;

  const PublicarScreen({
    super.key, 
    required this.username, 
    required this.password
  });

  @override
  State<PublicarScreen> createState() => _PublicarScreenState();
}

class _PublicarScreenState extends State<PublicarScreen> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  
  String _estadoSeleccionado = 'N/A'; 

  final List<File> _imagenes = [];
  final ImagePicker _picker = ImagePicker();
  bool _subiendo = false;

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
      if (foto != null) {
        setState(() {
          _imagenes.add(File(foto.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al abrir la galería"))
        );
      }
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
      if (foto != null) {
        setState(() {
          _imagenes.add(File(foto.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La cámara no está disponible en este dispositivo (PC)"),
            backgroundColor: Colors.orange,
          )
        );
      }
    }
  }

  void _publicar() async {
    if (_descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La descripción es obligatoria"))
      );
      return;
    }

    setState(() => _subiendo = true);

    final servicio = ObjetosService();
    final exito = await servicio.crearObjeto(
      titulo: _tituloCtrl.text,
      descripcion: _descCtrl.text,
      ubicacion: _ubicacionCtrl.text,
      estado: _estadoSeleccionado,
      imagenes: _imagenes,
      user: widget.username,
      pass: widget.password
    );

    setState(() => _subiendo = false);

    if (exito) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Publicado con éxito! "))
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al subir. Revisa tu conexión."))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Publicación"),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloCtrl,
              decoration: InputDecoration(
                labelText: "Título (Opcional)",
                hintText: "Ej: Llaves, Carnet, Venta...",
                prefixIcon: const Icon(Icons.title, color: Color(0xFF0033A0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: InputDecoration(
                labelText: "Estado del objeto / Tipo",
                prefixIcon: const Icon(Icons.info_outline, color: Color(0xFF0033A0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: const [
                DropdownMenuItem(value: 'N/A', child: Text("N/A - Ninguna (Por defecto)")),
                DropdownMenuItem(value: 'PERDIDO', child: Text("Buscando / Perdido")),
                DropdownMenuItem(value: 'ENCONTRADO', child: Text("Encontrado")),
              ], 
              onChanged: (val) => setState(() => _estadoSeleccionado = val!),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Descripción",
                hintText: "¿Qué encontraste? ¿Qué buscas?",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _ubicacionCtrl,
              decoration: InputDecoration(
                labelText: "Ubicación",
                hintText: "Ej: Bloque Sierra Nevada",
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF0033A0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Agregar Fotos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _botonFoto(Icons.camera_alt, _tomarFoto),
                  const SizedBox(width: 10),
                  _botonFoto(Icons.photo_library, _seleccionarFoto),
                  const SizedBox(width: 10),
                  
                  ..._imagenes.map((file) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                        ),
                      ),
                      Positioned(
                        top: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _imagenes.remove(file)),
                          child: Container(
                            color: Colors.black54,
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6C00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _subiendo ? null : _publicar,
                child: _subiendo 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("PUBLICAR AHORA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _botonFoto(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[400]!)
        ),
        child: Icon(icon, color: Colors.grey[700], size: 30),
      ),
    );
  }
}