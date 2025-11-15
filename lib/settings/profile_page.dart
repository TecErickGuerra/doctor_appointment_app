import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController conditionsController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        nameController.text = userDoc['fullName'] ?? "";
        phoneController.text = userDoc['phone'] ?? "";
        conditionsController.text = userDoc['medicalConditions'] ?? "";
      });
    }
  }

  Future<void> saveUserInfo() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'fullName': nameController.text,
      'phone': phoneController.text,
      'medicalConditions': conditionsController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Información guardada"),
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
  // --------------------  DISEÑO iOS (CLEAN) ---------------------
  // -------------------------------------------------------------
  Widget _buildCupertinoPage() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Perfil"),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(22),
          children: [
            SizedBox(height: 20),

            // Avatar minimalista
            Center(
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
            SizedBox(height: 12),

            Center(
              child: Text(
                user?.email ?? "",
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Inputs estilo iOS
            _cupertinoInput("Nombre completo", nameController),
            SizedBox(height: 20),

            _cupertinoInput("Teléfono", phoneController),
            SizedBox(height: 20),

            _cupertinoInput("Condiciones médicas", conditionsController),
            SizedBox(height: 30),

            // Botón guardar
            CupertinoButton.filled(
              child: Text("Guardar información"),
              onPressed: saveUserInfo,
            ),

            SizedBox(height: 10),

            // Botón inicio
            CupertinoButton(
              child: Text("Volver al inicio"),
              onPressed: () => Navigator.pop(context),
            ),

            SizedBox(height: 10),

            // Botón cerrar sesión
            CupertinoButton(
              child: Text(
                "Cerrar sesión",
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Input Cupertino
  Widget _cupertinoInput(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // -------------------  DISEÑO ANDROID CLEAN --------------------
  // -------------------------------------------------------------
  Widget _buildMaterialPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil", style: TextStyle(fontWeight: FontWeight.w500)),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(22),
        children: [
          SizedBox(height: 20),

          // Avatar limpio estilo Google
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.person,
                size: 55,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(height: 12),

          Center(
            child: Text(
              user?.email ?? "",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),

          SizedBox(height: 30),

          _materialInput("Nombre completo", nameController),
          SizedBox(height: 20),

          _materialInput("Teléfono", phoneController),
          SizedBox(height: 20),

          _materialInput("Condiciones médicas", conditionsController),
          SizedBox(height: 30),

          // Botón guardar
          FilledButton(
            onPressed: saveUserInfo,
            child: Text("Guardar información"),
          ),
          SizedBox(height: 10),

          // Volver
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Volver al inicio"),
          ),
          SizedBox(height: 10),

          // Cerrar sesión
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            child: Text(
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