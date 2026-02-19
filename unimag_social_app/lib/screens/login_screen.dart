import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'feed_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn)
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final res = await _authService.login(
      _emailController.text.trim(), 
      _passController.text
    );
    setState(() => _isLoading = false);

    if (res['success']) {
      final token = res['data']['token'];
      final user = res['data']['username'];
      
      await _authService.guardarSesion(token, user);
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (_) => const FeedScreen()
        )
      );
    } else {
      _showSnack(res['message'] ?? "Error al entrar", Colors.red);
    }
  }

  void _mostrarModalRecuperacion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 
          30, 
          20, 
          MediaQuery.of(context).viewInsets.bottom + 20
        ),
        child: _FormularioRecuperacion(authService: _authService),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color)
    );
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
                colors: [
                  Color(0xFF0033A0), 
                  Color(0xFF0055D4), 
                  Color(0xFF001A50)
                ],
              ),
            ),
          ),

          Positioned(top: -50, left: -50, child: _CircleDecor(200)),
          Positioned(bottom: -100, right: -50, child: _CircleDecor(300)),

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
                      child: Image.asset(
                        'assets/umi-logo.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hecho para estudiantes, por estudiantes.", 
                      style: TextStyle(
                        color: Colors.white70, 
                        fontSize: 18
                      )
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26, 
                            blurRadius: 20, 
                            offset: Offset(0, 10)
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "¡Bienvenido!",
                            style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF0033A0)
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecor(
                              "Correo Institucional", 
                              Icons.email_outlined
                            ),
                          ),
                          const SizedBox(height: 15),

                          TextFormField(
                            controller: _passController,
                            obscureText: true,
                            decoration: _inputDecor(
                              "Contraseña", 
                              Icons.lock_outline
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _mostrarModalRecuperacion,
                              child: const Text(
                                "¿Olvidaste tu contraseña?", 
                                style: TextStyle(
                                  color: Color(0xFF0033A0), 
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6C00),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                elevation: 5,
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading 
                                ? const CircularProgressIndicator(
                                    color: Colors.white
                                  )
                                : const Text(
                                    "INICIAR SESIÓN",
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.white
                                    )
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿No tienes cuenta? ", 
                          style: TextStyle(color: Colors.white70)
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => const RegisterScreen())
                            );
                          },
                          child: const Text(
                            "Regístrate",
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              decoration: TextDecoration.underline
                            ),
                          ),
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

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0033A0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: BorderSide.none
      ),
     

      contentPadding: const EdgeInsets.symmetric(
        vertical: 18, 
        horizontal: 20
      ),
    );
  }
}

class _CircleDecor extends StatelessWidget {
  final double size;
  const _CircleDecor(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, 
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: Colors.white.withOpacity(0.05)
      ),
    );
  }
}

class _FormularioRecuperacion extends StatefulWidget {
  final AuthService authService;
  const _FormularioRecuperacion({required this.authService});

  @override
  State<_FormularioRecuperacion> createState() => _FormularioRecuperacionState();
}

class _FormularioRecuperacionState extends State<_FormularioRecuperacion> {
  int _paso = 1;
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _enviarCodigo() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    final exito = await widget.authService
        .solicitarRecuperacion(_emailCtrl.text.trim());

    setState(() => _loading = false);

    if (exito) {
      setState(() => _paso = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Verifica el correo")
        )
      );
    }
  }

  void _confirmarCambio() async {
    if (_codigoCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _loading = true);

    final res = await widget.authService.confirmarRecuperacion(
      _emailCtrl.text.trim(), 
      _codigoCtrl.text.trim(), 
      _passCtrl.text
    );

    setState(() => _loading = false);

    if (res.containsKey('mensaje')) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Contraseña cambiada! Inicia sesión."), 
          backgroundColor: Colors.green
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? "Error"), 
          backgroundColor: Colors.red
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40, 
            height: 5, 
            decoration: BoxDecoration(
              color: Colors.grey[300], 
              borderRadius: BorderRadius.circular(10)
            )
          )
        ),
        const SizedBox(height: 20),
        
        Text(
          _paso == 1 
            ? "Recuperar Acceso" 
            : "Establecer Nueva Clave",
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFF0033A0)
          )
        ),
        const SizedBox(height: 10),
        Text(
          _paso == 1 
            ? "Ingresa tu correo institucional. Te enviaremos un código de seguridad de 6 dígitos." 
            : "Revisa tu bandeja de entrada e ingresa el código.",
          style: TextStyle(color: Colors.grey[600])
        ),
        const SizedBox(height: 30),
        
        if (_paso == 1) ...[
          TextField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              labelText: "Correo Unimag", 
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity, 
            height: 55, 
            child: ElevatedButton(
              onPressed: _loading ? null : _enviarCodigo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0033A0), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                )
              ),
              child: _loading 
                ? const CircularProgressIndicator(
                    color: Colors.white
                  )
                : const Text(
                    "ENVIAR CÓDIGO", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16
                    )
                  ),
            )
          )
        ] else ...[
          TextField(
            controller: _codigoCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Código (6 dígitos)", 
              prefixIcon: const Icon(Icons.lock_clock_outlined), 
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
              )
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Nueva Contraseña", 
              prefixIcon: const Icon(Icons.key_rounded), 
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
              )
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity, 
            height: 55, 
            child: ElevatedButton(
              onPressed: _loading ? null : _confirmarCambio,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6C00), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                )
              ),
              child: _loading 
                ? const CircularProgressIndicator(
                    color: Colors.white
                  )
                : const Text(
                    "CAMBIAR CONTRASEÑA", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16
                    )
                  ),
            )
          )
        ]
      ],
    );
  }
}