import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController conditionsController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  String? _selectedRole; // 👈 nuevo campo para el rol

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users') // 👈 asegúrate que coincide con tu colección real
        .doc(user!.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        nameController.text = data['nombre'] ?? "";
        phoneController.text = data['telefono'] ?? "";
        conditionsController.text = data['padecimientos'] ?? "";
        _selectedRole = data['rol']; // 👈 carga el rol guardado
      });
    }
  }

  Future<void> saveUserInfo() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'nombre': nameController.text,
      'telefono': phoneController.text,
      'padecimientos': conditionsController.text,
      'rol': _selectedRole, // 👈 guarda también el rol
      'actualizadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Información guardada correctamente"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildCupertinoPage() : _buildMaterialPage();
  }

  // -------------------------------------------------------------
  // --------------------  DISEÑO iOS -----------------------------
  // -------------------------------------------------------------
  Widget _buildCupertinoPage() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Perfil"),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 20),

            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: CupertinoColors.systemGrey5,
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Text(
                user?.email ?? "",
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 30),

            _cupertinoInput("Nombre completo", nameController),
            const SizedBox(height: 20),

            _cupertinoInput("Teléfono", phoneController),
            const SizedBox(height: 20),

            _cupertinoInput("Condiciones médicas", conditionsController),
            const SizedBox(height: 20),

            // 👇 Nuevo: Selector de rol
            const Text(
              "Rol del usuario",
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 6),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => CupertinoActionSheet(
                    title: const Text("Selecciona tu rol"),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() => _selectedRole = "Paciente");
                          Navigator.pop(context);
                        },
                        child: const Text("Paciente"),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() => _selectedRole = "Médico");
                          Navigator.pop(context);
                        },
                        child: const Text("Médico"),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedRole ?? "Selecciona tu rol",
                      style: const TextStyle(
                          color: CupertinoColors.black, fontSize: 16)),
                  const Icon(CupertinoIcons.chevron_down,
                      size: 18, color: CupertinoColors.systemGrey),
                ],
              ),
            ),

            const SizedBox(height: 30),

            CupertinoButton.filled(
              child: const Text("Guardar información"),
              onPressed: saveUserInfo,
            ),
            const SizedBox(height: 10),

            CupertinoButton(
              child: const Text("Volver al inicio"),
              onPressed: () => Navigator.pop(context),
            ),

            const SizedBox(height: 10),

            CupertinoButton(
              child: const Text(
                "Cerrar sesión",
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _cupertinoInput(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // -------------------  DISEÑO MATERIAL -------------------------
  // -------------------------------------------------------------
  Widget _buildMaterialPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 20),

          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person,
                  size: 55, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: Text(
              user?.email ?? "",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 30),

          _materialInput("Nombre completo", nameController),
          const SizedBox(height: 20),

          _materialInput("Teléfono", phoneController),
          const SizedBox(height: 20),

          _materialInput("Condiciones médicas", conditionsController),
          const SizedBox(height: 20),

          // 👇 Dropdown del rol
          InputDecorator(
            decoration: InputDecoration(
              labelText: "Rol del usuario",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                hint: const Text("Selecciona tu rol"),
                items: const [
                  DropdownMenuItem(
                      value: "Paciente", child: Text("Paciente")),
                  DropdownMenuItem(value: "Médico", child: Text("Médico")),
                ],
                onChanged: (value) =>
                    setState(() => _selectedRole = value),
              ),
            ),
          ),

          const SizedBox(height: 30),

          FilledButton(
            onPressed: saveUserInfo,
            child: const Text("Guardar información"),
          ),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Volver al inicio"),
          ),
          const SizedBox(height: 10),

          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (_) => false);
              }
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
