import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // ======================================================
  // AUTH FUNCTIONS
  // ======================================================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _showCupertinoAlert("Bienvenido ${user.user!.email}");

      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushReplacementNamed(context, Routes.home);
      });
    } on FirebaseAuthException catch (e) {
      String msg = switch (e.code) {
        'user-not-found' => 'Usuario no encontrado',
        'wrong-password' => 'Contraseña incorrecta',
        _ => e.message ?? 'Error desconocido',
      };
      _showCupertinoAlert(msg);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _showCupertinoAlert("Cuenta creada: ${userCredential.user!.email}");

      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushReplacementNamed(context, Routes.home);
      });
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'El correo ya está en uso',
        'weak-password' => 'Contraseña demasiado débil',
        _ => e.message ?? 'Error desconocido',
      };
      _showCupertinoAlert(message);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resetPassword() async {
    if (emailController.text.isEmpty) {
      _showCupertinoAlert("Ingresa tu correo para restablecer contraseña");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      _showCupertinoAlert(
        "Se ha enviado un correo a ${emailController.text}",
      );
    } on FirebaseAuthException catch (e) {
      _showCupertinoAlert(e.message ?? "Error desconocido");
    }
  }

  // ======================================================
  // ALERT
  // ======================================================
  void _showCupertinoAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            children: [
              // ======================================================
              // LOGO CÍRCULO MÉDICO
              // ======================================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8A8),
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                width: 130,
                height: 130,
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 30),

              // ======================================================
              // TITULOS
              // ======================================================
              const Text(
                "Citas Médicas",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF007E7E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Inicio de sesión",
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),

              const SizedBox(height: 34),

              // ======================================================
              // FORMULARIO TARJETA
              // ======================================================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // EMAIL
                      _buildInputField(
                        controller: emailController,
                        placeholder: "Correo electrónico",
                        icon: CupertinoIcons.mail_solid,
                      ),
                      const SizedBox(height: 16),

                      // PASSWORD
                      _buildInputField(
                        controller: passwordController,
                        placeholder: "Contraseña",
                        obscureText: true,
                        icon: CupertinoIcons.lock_fill,
                      ),

                      const SizedBox(height: 30),

                      // BOTÓN LOGIN
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text("Iniciar sesión"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======================================================
              // REGISTRO / OLVIDASTE CONTRASEÑA
              // ======================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _isLoading ? null : _register,
                    child: const Text("Crear cuenta"),
                  ),
                  Container(
                    width: 1,
                    height: 22,
                    color: Colors.grey.shade400,
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.only(left: 12),
                    onPressed: _isLoading ? null : _resetPassword,
                    child: const Text("Recuperar contraseña"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // WIDGET INPUT CUSTOM
  // ======================================================
  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
  }) {
    return CupertinoTextField(
      controller: controller,
      obscureText: obscureText,
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Icon(
          icon,
          color: Colors.teal.shade400,
          size: 20,
        ),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }
}
