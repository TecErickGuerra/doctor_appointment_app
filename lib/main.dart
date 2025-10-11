import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Citas Médicas',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF00BFA6),
          secondary: const Color(0xFF00796B),
          background: const Color(0xFFF1F8F6),
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido ${user.user!.email}')),
      );
    } on FirebaseAuthException catch (e) {
      String msg = switch (e.code) {
        'user-not-found' => 'Usuario no encontrado',
        'wrong-password' => 'Contraseña incorrecta',
        _ => e.message ?? 'Error desconocido',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F6),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LOGO
              Image.asset(
                'assets/images/cita_logo.png',
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido a Citas Médicas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Inicia sesión para continuar",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de correo
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        labelText: 'Correo electrónico',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su correo' : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo de contraseña
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su contraseña' : null,
                    ),
                    const SizedBox(height: 30),

                    // Botón login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Enlace de registro
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Cuenta creada: ${userCredential.user!.email}")),
                            );
                          } on FirebaseAuthException catch (e) {
                            String message = "";
                            if (e.code == 'email-already-in-use') {
                              message = "El correo ya está en uso";
                            } else if (e.code == 'weak-password') {
                              message = "Contraseña demasiado débil";
                            } else {
                              message = e.message ?? "Error desconocido";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      },
                      child: const Text("¿No tienes cuenta? Regístrate aquí"),
                    ),
                    const SizedBox(height: 10),

                    // Enlace de recuperación
                    TextButton(
                      onPressed: () async {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ingresa tu correo para restablecer la contraseña")),
                          );
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Se ha enviado un correo para restablecer la contraseña")),
                          );
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? "Error desconocido")),
                          );
                        }
                      },
                      child: const Text("¿Olvidaste tu contraseña?"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
