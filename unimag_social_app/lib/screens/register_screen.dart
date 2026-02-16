import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

const List<Map<String, String>> CARRERAS_UNIMAG = [
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _carreraSeleccionada;

  int _paso = 1; 
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _solicitarCodigo() async {
    if (_emailCtrl.text.isEmpty || !_emailCtrl.text.contains('@unimagdalena.edu.co')) {
      _snack("Usa tu correo institucional (@unimagdalena.edu.co)", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    final errorMsg = await _authService.solicitarCodigo(_emailCtrl.text.trim());
    setState(() => _isLoading = false);

    if (errorMsg == null) {
      _snack("¡Código enviado! Revisa tu correo.", Colors.green);
      setState(() => _paso = 2);
    } else {
      _snack(errorMsg, Colors.red);
    }
  }

  void _registrarse() async {
    if (_codigoCtrl.text.isEmpty || _passCtrl.text.isEmpty || _carreraSeleccionada == null) {
      _snack("Por favor completa todos los campos", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    final res = await _authService.registrarUsuario(
      _emailCtrl.text.trim(),
      _codigoCtrl.text.trim(),
      _passCtrl.text,
      _carreraSeleccionada!
    );
    setState(() => _isLoading = false);

    if (res['success']) {
      _snack("¡Registro exitoso! Inicia sesión.", Colors.green);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      _snack(res['message'] ?? "Error en el registro", Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0033A0), Color(0xFF0055D4), Color(0xFF001A50)],
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Container(
                        height: 80, width: 80,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Image.asset('assets/umi-logo.png'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _paso == 1 ? "Crear Cuenta" : "Finalizar Registro",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0033A0)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _paso == 1 
                              ? "Ingresa tu correo institucional para verificar que eres estudiante."
                              : "Hemos enviado un código a ${_emailCtrl.text}. Ingrésalo abajo.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 25),

                          if (_paso == 1) ...[
                            _buildInput(_emailCtrl, "Correo Unimag", Icons.email_outlined, tipo: TextInputType.emailAddress),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity, height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _solicitarCodigo,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6C00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ENVIAR CÓDIGO DE VERIFICACIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],

                          if (_paso == 2) ...[
                            _buildInput(_codigoCtrl, "Código de 6 dígitos", Icons.lock_clock_outlined, tipo: TextInputType.number),
                            const SizedBox(height: 15),
                            _buildInput(_userCtrl, "Nombre de Usuario (Opcional)", Icons.person_outline),
                            const SizedBox(height: 15),
                            _buildInput(_passCtrl, "Contraseña", Icons.lock_outline, oculto: true),
                            const SizedBox(height: 15),
                            
                            DropdownButtonFormField<String>(
                              value: _carreraSeleccionada,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Selecciona tu Carrera",
                                prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF0033A0)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              items: CARRERAS_UNIMAG.map((c) => DropdownMenuItem(value: c['val'], child: Text(c['label']!, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => _carreraSeleccionada = val),
                            ),
                            
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity, height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _registrarse,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0033A0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("CREAR CUENTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            
                            TextButton(
                              onPressed: () => setState(() => _paso = 1),
                              child: const Text("Corregir correo", style: TextStyle(color: Colors.grey)),
                            )
                          ]
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes cuenta? ", style: TextStyle(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: const Text("Inicia Sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool oculto = false, TextInputType? tipo}) {
    return TextFormField(
      controller: ctrl,
      obscureText: oculto,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0033A0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}