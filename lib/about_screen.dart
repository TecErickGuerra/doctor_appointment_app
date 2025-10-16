import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo o icono de la app
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_hospital,
                  size: 60,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre de la app
            const Center(
              child: Text(
                'Doctor Appointment App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Versión
            Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Misión
            _buildInfoCard(
              icon: Icons.flag,
              title: 'Nuestra Misión',
              content:
                  'Facilitar el acceso a servicios médicos de calidad mediante una plataforma digital intuitiva que conecta a pacientes con profesionales de la salud, mejorando la experiencia de atención médica.',
              color: Colors.blue,
            ),

            // Visión
            _buildInfoCard(
              icon: Icons.visibility,
              title: 'Nuestra Visión',
              content:
                  'Ser la aplicación líder en gestión de citas médicas en México, revolucionando la forma en que las personas acceden a servicios de salud y promoviendo una atención médica más accesible y eficiente.',
              color: Colors.green,
            ),

            // Valores
            _buildInfoCard(
              icon: Icons.favorite,
              title: 'Nuestros Valores',
              content:
                  '• Compromiso con la salud del paciente\n'
                  '• Innovación tecnológica\n'
                  '• Confidencialidad y seguridad\n'
                  '• Accesibilidad para todos\n'
                  '• Excelencia en el servicio',
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            // Características
            const Text(
              'Características Principales',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeature(
              icon: Icons.calendar_today,
              title: 'Agenda de Citas',
              description: 'Programa y gestiona tus citas médicas fácilmente',
            ),
            _buildFeature(
              icon: Icons.person_search,
              title: 'Búsqueda de Especialistas',
              description: 'Encuentra el médico adecuado para tus necesidades',
            ),
            _buildFeature(
              icon: Icons.notifications_active,
              title: 'Recordatorios',
              description: 'Recibe notificaciones sobre tus próximas citas',
            ),
            _buildFeature(
              icon: Icons.history,
              title: 'Historial Médico',
              description: 'Accede a tu historial de consultas y tratamientos',
            ),

            const SizedBox(height: 32),

            // Información del equipo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👨‍💻 Desarrollado por:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Instituto Tecnológico de Software',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Proyecto académico - Cuatrimestre Actual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contacto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_phone, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Contáctanos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '📧 soporte@doctorapp.com\n'
                    '📞 +52 123 456 7890\n'
                    '🌐 www.doctorapp.com\n'
                    '📍 Ciudad de México, México',
                    style: TextStyle(fontSize: 15, height: 1.8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2025 Doctor Appointment App\nTodos los derechos reservados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget para tarjetas de información
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Widget para características
  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
