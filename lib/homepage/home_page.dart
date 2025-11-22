import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';
import '../settings/privacy_screen.dart';
import '../settings/about_screen.dart';
import 'appointments_page.dart';
import '../screens/dashboard/dashboard_screen.dart';

class HomePage extends StatefulWidget {
  final int initialIndex; // 👈 AGREGADO
  
  const HomePage({super.key, this.initialIndex = 0}); // 👈 MODIFICADO

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mensajes (estado local para poder eliminar con swipe)
  final List<Map<String, String>> _messages = [
    {"id": "1", "name": "Dr. Carlos Ramírez", "msg": "Hola, ¿cómo estás?", "time": "10:20 AM"},
    {"id": "2", "name": "Dra. Ana López", "msg": "Recordatorio de cita", "time": "10:21 AM"},
    {"id": "3", "name": "Dr. Pedro Martínez", "msg": "Resultados disponibles", "time": "10:22 AM"},
    {"id": "4", "name": "Dra. Laura Sánchez", "msg": "Confirma tu asistencia", "time": "10:23 AM"},
    {"id": "5", "name": "Dr. Roberto Torres", "msg": "Seguimiento", "time": "10:24 AM"},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 👈 AGREGADO
    print('HomePage inicializado con índice: $_selectedIndex'); //SE AGREGA LINEA AQUI
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  String _getUserName() {
    User? user = _auth.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user != null && user.email != null) {
      return user.email!.split('@')[0];
    }
    return "Usuario";
  }

  // 👇 NUEVA FUNCIÓN: Obtener rol del usuario
  Future<String?> _getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['rol'] ?? 'Paciente';
    } catch (e) {
      print('Error al obtener rol: $e');
      return 'Paciente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),      // índice 0 - Inicio
          const DashboardScreen(),  // índice 1 - Dashboard (real)
          _buildMessagesScreen(),   // índice 2 - Mensajes
          _buildSettingsScreen(),   // índice 3 - Configuración
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6c5ce7),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  // ==================== HOME CONTENT ====================
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con saludo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${_getUserName()}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¿En qué podemos ayudarte?',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 👇 TARJETAS CONDICIONALES SEGÚN EL ROL
            FutureBuilder<String?>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rol = snapshot.data ?? 'Paciente';

                return Column(
                  children: [
                    // Primera fila de tarjetas - CONDICIONAL
                    Row(
                      children: [
                        if (rol == 'Paciente') ...[
                          // PACIENTE ve: Agendar Cita
                          Expanded(
                            child: _buildMainCard(
                              title: 'Agendar Cita',
                              icon: Icons.event_available,
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AppointmentsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          // MÉDICO ve: Ver Dashboard
                          Expanded(
                            child: _buildMainCard(
                              title: 'Ver Dashboard',
                              icon: Icons.dashboard,
                              color: const Color(0xFF00A8A8),
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.dashboard);
                              },
                            ),
                          ),
                        ],
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMainCard(
                            title: 'Mensajes',
                            icon: Icons.message,
                            color: Colors.blue,
                            onTap: () {
                              setState(() => _selectedIndex = 2);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Segunda fila de tarjetas
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainCard(
                            title: 'Consejos',
                            icon: Icons.lightbulb,
                            color: Colors.orange,
                            onTap: () => _showMedicalTips(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMainCard(
                            title: rol == 'Médico' ? 'Mis Citas' : 'Mis Doctores',
                            icon: rol == 'Médico' ? Icons.calendar_today : Icons.people,
                            color: rol == 'Médico' ? const Color(0xFF6c5ce7) : Colors.teal,
                            onTap: () {
                              if (rol == 'Médico') {
                                setState(() => _selectedIndex = 1);
                              } else {
                                // Navegar a lista de doctores
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ver lista de doctores')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Especialistas
            const Text('Especialistas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSpecialistCard('Cardiólogo', Icons.favorite),
                  _buildSpecialistCard('Pediatra', Icons.child_care),
                  _buildSpecialistCard('Dermatólogo', Icons.face),
                  _buildSpecialistCard('Ginecólogo', Icons.pregnant_woman),
                  _buildSpecialistCard('Traumatólogo', Icons.accessibility_new),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Doctores destacados
            const Text('Doctores Destacados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDoctorCard('Dr. Carlos Ramírez', 'Cardiólogo', '4.8'),
            _buildDoctorCard('Dra. Ana López', 'Pediatra', '4.9'),
            _buildDoctorCard('Dr. Pedro Martínez', 'Dermatólogo', '4.7'),
            _buildDoctorCard('Dra. Laura Sánchez', 'Ginecóloga', '4.6'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(String name, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue.shade700),
          const SizedBox(height: 8),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(String name, String specialty, String rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 30, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(specialty, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showMedicalTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consejos Médicos'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTip('💊 Dolor de cabeza', 'Descansa en un lugar oscuro y silencioso. Mantente hidratado.'),
              _buildTip('🤧 Resfriado común', 'Toma líquidos calientes, descansa y usa vapor para descongestionar.'),
              _buildTip('🦷 Dolor de muelas', 'Enjuaga con agua tibia y sal. Evita alimentos duros.'),
              _buildTip('🔥 Fiebre leve', 'Mantente hidratado, usa compresas frescas y descansa.'),
              const SizedBox(height: 12),
              const Text(
                '⚠ Si los síntomas persisten, consulta a un médico.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // ==================== MENSAJES ====================
  Widget _buildMessagesScreen() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: Colors.white,
            width: double.infinity,
            child: const Text('Mensajes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No hay mensajes', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final item = _messages[index];
                      return Dismissible(
                        key: ValueKey(item['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() => _messages.removeAt(index));
                        },
                        child: Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(item['name']!),
                            subtitle: Text(item['msg']!),
                            trailing: Text(item['time']!),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== CONFIGURACIÓN ====================
  Widget _buildSettingsScreen() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsOption(
            icon: Icons.person,
            title: 'Perfil',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          _buildSettingsOption(
            icon: Icons.privacy_tip,
            title: 'Privacidad',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
            ),
          ),
          _buildSettingsOption(
            icon: Icons.info,
            title: 'Sobre Nosotros',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
          ),
          const Divider(height: 32),
          _buildSettingsOption(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            color: Colors.red,
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}