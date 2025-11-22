import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/dashboard/task_card_widget.dart';
import '../../widgets/dashboard/project_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              // 👇 STREAMBUILDER PARA DATOS EN TIEMPO REAL
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('citas')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  // 📊 CÁLCULO DE ESTADÍSTICAS DINÁMICAS
                  final citas = snapshot.data?.docs ?? [];
                  final totalCitas = citas.length;
                  final citasHoy = _getCitasHoy(citas);
                  final citasPendientes = citas
                      .where((c) => (c.data() as Map)['estado'] == 'Pendiente')
                      .length;
                  final citasCompletadas = citas
                      .where((c) => (c.data() as Map)['estado'] == 'Completada')
                      .length;

                  // 📊 PACIENTES ÚNICOS
                  final pacientesUnicos = <String>{};
                  for (var cita in citas) {
                    final data = cita.data() as Map;
                    if (data['pacienteId'] != null) {
                      pacientesUnicos.add(data['pacienteId']);
                    }
                  }
                  final totalPacientes = pacientesUnicos.length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(
                          context,
                          citasHoy: citasHoy,
                          totalPacientes: totalPacientes,
                          totalCitas: totalCitas,
                          citasCompletadas: citasCompletadas,
                        ),
                        const SizedBox(height: 24),
                        _buildAppointmentsSection(context, citas),
                        const SizedBox(height: 24),
                        _buildDepartmentsSection(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📅 FUNCIÓN: Obtener citas de hoy
  int _getCitasHoy(List<QueryDocumentSnapshot> citas) {
    final hoy = DateTime.now();
    final hoyStr = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    
    return citas.where((c) {
      final data = c.data() as Map;
      return data['fecha'] == hoyStr;
    }).length;
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
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
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

  // ==================== STATS CARDS (DINÁMICAS) ====================
  // En _buildStatsCards, después del cuarto card, agrega:
Widget _buildStatsCards(
  BuildContext context, {
  required int citasHoy,
  required int totalPacientes,
  required int totalCitas,
  required int citasCompletadas,
}) {
  return GridView.count(
    crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.5,
    children: [
      // ... tus 4 cards existentes ...
      
      // 👈 NUEVA CARD PARA ESTADÍSTICAS (opcional)
      _buildStatCard(
        title: 'Ver Gráficas',
        value: '📊',
        icon: Icons.insights,
        color: const Color(0xFF9C27B0), // Color morado
        trend: 'Analizar',
        onTap: () {
          Navigator.pushNamed(context, '/graphics');
        },
      ),
    ],
  );
}

// Actualiza _buildStatCard para aceptar onTap
Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required String trend,
  VoidCallback? onTap, // 👈 Parámetro opcional
}) {
  return InkWell(
    onTap: onTap, // 👈 Si se proporciona onTap, hace clickeable
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1d2e),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // ==================== APPOINTMENTS SECTION (DINÁMICA) ====================
  Widget _buildAppointmentsSection(
    BuildContext context,
    List<QueryDocumentSnapshot> citas,
  ) {
    final citasRecientes = citas.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Citas Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1d2e),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (citasRecientes.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No hay citas registradas'),
            ),
          )
        else
          ...citasRecientes.map((cita) {
            final data = cita.data() as Map<String, dynamic>;
            final estado = data['estado'] ?? 'Pendiente';
            Color statusColor;

            switch (estado) {
              case 'Completada':
                statusColor = Colors.green;
                break;
              case 'Cancelada':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCardWidget(
                title: data['motivo'] ?? 'Consulta',
                subtitle: '${data['fecha']} - ${data['hora']}',
                status: estado,
                statusColor: statusColor,
                patient: data['paciente'] ?? 'Sin nombre',
              ),
            );
          }).toList(),
      ],
    );
  }

  // ==================== DEPARTMENTS SECTION ====================
  Widget _buildDepartmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Departamentos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1d2e),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            ProjectCardWidget(
              title: 'Cardiología',
              subtitle: '12 Doctores',
              icon: Icons.favorite,
              color: Colors.red,
            ),
            ProjectCardWidget(
              title: 'Neurología',
              subtitle: '8 Doctores',
              icon: Icons.psychology,
              color: Colors.purple,
            ),
            ProjectCardWidget(
              title: 'Pediatría',
              subtitle: '15 Doctores',
              icon: Icons.child_care,
              color: Colors.blue,
            ),
            ProjectCardWidget(
              title: 'Traumatología',
              subtitle: '10 Doctores',
              icon: Icons.healing,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  // ==================== QUICK ACTIONS ====================
// ==================== QUICK ACTIONS ====================
Widget _buildQuickActions(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Acciones Rápidas',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1a1d2e),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.add_circle,
              label: 'Nueva Cita',
              color: const Color(0xFF6c5ce7),
              onTap: () {
                _showNuevaCitaDialog(context);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.person_add,
              label: 'Nuevo Paciente',
              color: const Color(0xFF00D4FF),
              onTap: () {
                _showNuevoPacienteDialog(context);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.bar_chart, // 👈 NUEVO ICONO
              label: 'Estadísticas', // 👈 NUEVO TEXTO
              color: const Color(0xFFFFA726), // 👈 NUEVO COLOR (naranja)
              onTap: () {
                // 👈 NUEVA NAVEGACIÓN
                Navigator.pushNamed(context, '/graphics');
              },
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DIÁLOGOS Y FUNCIONES ====================

// 📅 NUEVA CITA
void _showNuevaCitaDialog(BuildContext context) {
  final TextEditingController pacienteController = TextEditingController();
  final TextEditingController motivoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nueva Cita'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pacienteController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Paciente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de la Cita',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                hintText: '2025-11-20',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: horaController,
              decoration: const InputDecoration(
                labelText: 'Hora',
                border: OutlineInputBorder(),
                hintText: '10:00 AM',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (pacienteController.text.isNotEmpty &&
                motivoController.text.isNotEmpty &&
                fechaController.text.isNotEmpty &&
                horaController.text.isNotEmpty) {
              try {
                // Guardar en Firebase
                await FirebaseFirestore.instance.collection('citas').add({
                  'paciente': pacienteController.text,
                  'pacienteId': 'auto_${DateTime.now().millisecondsSinceEpoch}',
                  'motivo': motivoController.text,
                  'fecha': fechaController.text,
                  'hora': horaController.text,
                  'estado': 'Pendiente',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor completa todos los campos'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

// 👤 NUEVO PACIENTE
void _showNuevoPacienteDialog(BuildContext context) {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nuevo Paciente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nombreController.text.isNotEmpty &&
                emailController.text.isNotEmpty) {
              try {
                await FirebaseFirestore.instance.collection('pacientes').add({
                  'nombre': nombreController.text,
                  'email': emailController.text,
                  'telefono': telefonoController.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paciente registrado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

// 📊 VER REPORTES
void _showReportesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reportes'),
      content: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('citas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final citas = snapshot.data!.docs;
          final total = citas.length;
          final pendientes = citas
              .where((c) => (c.data() as Map)['estado'] == 'Pendiente')
              .length;
          final completadas = citas
              .where((c) => (c.data() as Map)['estado'] == 'Completada')
              .length;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReporteItem('Total de Citas', total.toString(), Icons.calendar_month),
              const SizedBox(height: 12),
              _buildReporteItem('Pendientes', pendientes.toString(), Icons.pending),
              const SizedBox(height: 12),
              _buildReporteItem('Completadas', completadas.toString(), Icons.check_circle),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Aquí podrías exportar a PDF o generar un reporte completo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Generando reporte...'),
              ),
            );
          },
          child: const Text('Descargar PDF'),
        ),
      ],
    ),
  );
}

Widget _buildReporteItem(String label, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF6c5ce7), size: 32),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1d2e),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}