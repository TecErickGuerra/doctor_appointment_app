import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes.dart';
import '../settings/privacy_screen.dart';
import '../settings/about_screen.dart';
import 'appointments_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getUserName() {
    User? user = _auth.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user != null && user.email != null) {
      return user.email!.split('@')[0];
    }
    return "Usuario";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),      // índice 0 - Inicio
          _buildDashboardScreen(),  // índice 1 - Dashboard (NUEVO)
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
            Row(
              children: [
                Expanded(
                  child: _buildMainCard(
                    title: 'Agendar Cita',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppointmentsPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMainCard(
                    title: 'Dashboard',
                    icon: Icons.dashboard,
                    color: const Color(0xFF6c5ce7),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    title: 'Mensajes',
                    icon: Icons.message,
                    color: Colors.blue,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            const Text('Doctores Destacados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDoctorCard('Dr. Carlos Ramírez', 'Cardiólogo', '4.8'),
            _buildDoctorCard('Dra. Ana López', 'Pediatra', '4.9'),
            _buildDoctorCard('Dr. Pedro Martínez', 'Dermatólogo', '4.7'),
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
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
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
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          CircleAvatar(radius: 30, backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, size: 30, color: Colors.blue.shade700)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(specialty, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ]),
          ),
          Row(children: [const Icon(Icons.star, color: Colors.amber, size: 20), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            _buildTip('💊 Dolor de cabeza', 'Descansa en un lugar oscuro y silencioso. Mantente hidratado.'),
            _buildTip('🤧 Resfriado común', 'Toma líquidos calientes, descansa y usa vapor para descongestionar.'),
            _buildTip('🦷 Dolor de muelas', 'Enjuaga con agua tibia y sal. Evita alimentos duros.'),
            _buildTip('🔥 Fiebre leve', 'Mantente hidratado, usa compresas frescas y descansa.'),
            const SizedBox(height: 12),
            const Text('⚠ Si los síntomas persisten, consulta a un médico.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.red)),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))]));
  }

  // ==================== DASHBOARD SCREEN ====================
  Widget _buildDashboardScreen() {
    return SafeArea(
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width > 768) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildDashboardHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildAppointmentsSection(),
                        const SizedBox(height: 24),
                        _buildDepartmentsSection(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF0f1117),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6c5ce7), Color(0xFF8b5cf6)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medical_services, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medical App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Dashboard', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildSidebarMenuItem(icon: Icons.home, title: 'Inicio', onTap: () => setState(() => _selectedIndex = 0)),
          _buildSidebarMenuItem(icon: Icons.dashboard, title: 'Dashboard', isActive: true, onTap: () {}),
          _buildSidebarMenuItem(icon: Icons.calendar_today, title: 'Citas', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentsPage()))),
          _buildSidebarMenuItem(icon: Icons.message, title: 'Mensajes', onTap: () => setState(() => _selectedIndex = 2)),
          _buildSidebarMenuItem(icon: Icons.person, title: 'Perfil', onTap: () => Navigator.pushNamed(context, Routes.profile)),
          const Spacer(),
          _buildSidebarMenuItem(icon: Icons.logout, title: 'Cerrar Sesión', onTap: () async {
            await _auth.signOut();
            Navigator.pushReplacementNamed(context, Routes.login);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem({required IconData icon, required String title, bool isActive = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: isActive ? const Color(0xFF6c5ce7).withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFF6c5ce7) : Colors.grey, size: 22),
        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenido Doctor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a1d2e))),
              Text(_getCurrentDate(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1')),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(title: 'Citas Hoy', value: '15', icon: Icons.calendar_today, color: const Color(0xFF6c5ce7), trend: '+12%'),
        _buildStatCard(title: 'Pacientes', value: '234', icon: Icons.people, color: const Color(0xFF00D4FF), trend: '+8%'),
        _buildStatCard(title: 'Consultas', value: '89', icon: Icons.medical_services, color: const Color(0xFFFF6B6B), trend: '+15%'),
        _buildStatCard(title: 'Ingresos', value: '\$12.5k', icon: Icons.attach_money, color: const Color(0xFF4ECB71), trend: '+20%'),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, required String trend}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(trend, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1a1d2e))),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Citas de Hoy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1d2e))),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentsPage())), child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(patientName: 'Juan Pérez', time: '10:00 AM', type: 'Consulta General', status: 'Pendiente', statusColor: Colors.orange),
        const SizedBox(height: 12),
        _buildAppointmentCard(patientName: 'María García', time: '11:30 AM', type: 'Seguimiento', status: 'En Progreso', statusColor: Colors.blue),
        const SizedBox(height: 12),
        _buildAppointmentCard(patientName: 'Carlos López', time: '2:00 PM', type: 'Control', status: 'Completado', statusColor: Colors.green),
      ],
    );
  }

  Widget _buildAppointmentCard({required String patientName, required String time, required String type, required String status, required Color statusColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.person, color: statusColor)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$time - $type', style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)), child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildDepartmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Departamentos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1d2e))),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildDepartmentCard(name: 'Cardiología', doctors: '12 Doctores', icon: Icons.favorite, color: Colors.red),
            _buildDepartmentCard(name: 'Neurología', doctors: '8 Doctores', icon: Icons.psychology, color: Colors.purple),
            _buildDepartmentCard(name: 'Pediatría', doctors: '15 Doctores', icon: Icons.child_care, color: Colors.blue),
            _buildDepartmentCard(name: 'Traumatología', doctors: '10 Doctores', icon: Icons.healing, color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentCard({required String name, required String doctors, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(doctors, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acciones Rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1d2e))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildQuickActionButton(icon: Icons.add_circle, label: 'Nueva Cita', color: const Color(0xFF6c5ce7), onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickActionButton(icon: Icons.person_add, label: 'Nuevo Paciente', color: const Color(0xFF00D4FF), onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickActionButton(icon: Icons.receipt_long, label: 'Ver Reportes', color: const Color(0xFF4ECB71), onTap: () {})),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(children: [Icon(icon, color: Colors.white, size: 32), const SizedBox(height: 8), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)]),
      ),
    );
  }

  // ==================== MESSAGES SCREEN ====================
  Widget _buildMessagesScreen() {
    return SafeArea(
      child: Column(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), width: double.infinity, color: Colors.white, child: const Text('Mensajes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
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
                        background: Container(padding: const EdgeInsets.only(right: 20), alignment: Alignment.centerRight, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (direction) {
                          final removedName = item['name'];
                          setState(() => _messages.removeAt(index));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversación con $removedName eliminada')));
                        },
                        child: _buildMessageCard(item['name']!, item['msg']!, item['time']!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String name, String message, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, color: Colors.blue.shade700)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        trailing: Text(time, style: const TextStyle(fontSize: 12)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abriendo chat con $name'))),
      ),
    );
  }

  // ==================== SETTINGS SCREEN ====================
  Widget _buildSettingsScreen() {
    return SafeArea(
      child: Column(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), width: double.infinity, color: Colors.white, child: const Text('Configuración', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSettingsOption(icon: Icons.person, title: 'Perfil', onTap: () => Navigator.pushNamed(context, Routes.profile)),
                _buildSettingsOption(icon: Icons.privacy_tip, title: 'Privacidad', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen()))),
                _buildSettingsOption(icon: Icons.info, title: 'Sobre Nosotros', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()))),
                const Divider(height: 32),
                _buildSettingsOption(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  color: Colors.red,
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, Routes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({required IconData icon, required String title, required VoidCallback onTap, Color color = Colors.blue}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: TextStyle(color: color)), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: onTap),
    );
  }
}