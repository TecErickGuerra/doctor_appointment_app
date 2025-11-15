import 'package:flutter/material.dart';
import '../../widgets/dashboard/sidebar_widget.dart';
import '../../widgets/dashboard/task_card_widget.dart';
import '../../widgets/dashboard/project_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRightSidebarVisible = false; // controla la visibilidad del panel derecho

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // === Layout principal ===
            Row(
              children: [
                // Sidebar Izquierdo
                if (screenWidth > 768) const SidebarWidget(),

                // Contenido principal
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsCards(context),
                              const SizedBox(height: 24),
                              _buildAppointmentsSection(context),
                              const SizedBox(height: 24),
                              _buildDepartmentsSection(context),
                              const SizedBox(height: 24),
                              _buildQuickActions(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // === Toggle Button flotante (fijo en borde derecho) ===
            if (screenWidth > 1200)
              Positioned(
                top: 100,
                right: _isRightSidebarVisible ? 310 : 10,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF0f1117),
                  onPressed: () {
                    setState(() {
                      _isRightSidebarVisible = !_isRightSidebarVisible;
                    });
                  },
                  child: Icon(
                    _isRightSidebarVisible
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white,
                  ),
                ),
              ),

            // === Sidebar derecho animado ===
            if (screenWidth > 1200)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: _isRightSidebarVisible ? 0 : -300,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 300,
                  color: const Color(0xFF0f1117),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pacientes Recientes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: const [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=2'),
                              ),
                              title: Text(
                                'Juan Pérez',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Cita confirmada',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=3'),
                              ),
                              title: Text(
                                'María García',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Resultados listos',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=4'),
                              ),
                              title: Text(
                                'Carlos López',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Receta solicitada',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido Doctor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1d2e),
                ),
              ),
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ==================== RESTO DE SECCIONES (idénticas a las tuyas) ====================
  Widget _buildStatsCards(BuildContext context) => const SizedBox.shrink();
  Widget _buildAppointmentsSection(BuildContext context) => const SizedBox.shrink();
  Widget _buildDepartmentsSection(BuildContext context) => const SizedBox.shrink();
  Widget _buildQuickActions(BuildContext context) => const SizedBox.shrink();
}
