import 'package:flutter/material.dart';

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
      backgroundColor: Colors.black, // Fondo negro estilo Facebook
      body: Stack(
        children: [
          // 1. EL CARRUSEL DE FOTOS
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagenes.length,
            onPageChanged: (index) {
              setState(() => _indiceActual = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer( // Permite hacer zoom con los dedos
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

          // 2. BOTÓN CERRAR (Arriba izquierda)
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. CONTADOR DE FOTOS (Arriba centro)
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