import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de privacidad
            Center(
              child: Icon(
                Icons.privacy_tip,
                size: 80,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // Título principal
            const Text(
              'Política de Privacidad',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de actualización
            Text(
              'Última actualización: Octubre 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Sección 1
            _buildSection(
              title: '1. Información que Recopilamos',
              content:
                  'En Doctor Appointment App recopilamos información personal como nombre, correo electrónico, número de teléfono, fecha de nacimiento y datos médicos relevantes para proporcionar nuestros servicios de manera efectiva.',
            ),

            // Sección 2
            _buildSection(
              title: '2. Uso de la Información',
              content:
                  'Utilizamos tu información para:\n'
                  '• Gestionar y confirmar tus citas médicas\n'
                  '• Comunicarnos contigo sobre servicios\n'
                  '• Mejorar la experiencia del usuario\n'
                  '• Cumplir con requisitos legales y regulatorios',
            ),

            // Sección 3
            _buildSection(
              title: '3. Protección de Datos',
              content:
                  'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal contra acceso no autorizado, alteración, divulgación o destrucción.',
            ),

            // Sección 4
            _buildSection(
              title: '4. Compartir Información',
              content:
                  'No vendemos ni compartimos tu información personal con terceros, excepto cuando sea necesario para proporcionar nuestros servicios (por ejemplo, con profesionales médicos) o cuando la ley lo requiera.',
            ),

            // Sección 5
            _buildSection(
              title: '5. Tus Derechos',
              content:
                  'Tienes derecho a:\n'
                  '• Acceder a tu información personal\n'
                  '• Corregir datos incorrectos\n'
                  '• Solicitar la eliminación de tus datos\n'
                  '• Revocar consentimientos otorgados',
            ),

            // Sección 6
            _buildSection(
              title: '6. Cookies y Tecnologías Similares',
              content:
                  'Utilizamos cookies y tecnologías similares para mejorar tu experiencia en la aplicación, analizar el uso y personalizar contenido.',
            ),

            // Sección 7
            _buildSection(
              title: '7. Cambios en la Política',
              content:
                  'Nos reservamos el derecho de actualizar esta política de privacidad. Te notificaremos sobre cambios significativos a través de la aplicación o por correo electrónico.',
            ),

            const SizedBox(height: 24),

            // Contacto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_mail, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Contacto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Si tienes preguntas sobre nuestra política de privacidad, contáctanos:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '📧 Email: privacidad@doctorapp.com\n'
                    '📞 Teléfono: +52 123 456 7890\n'
                    '🏢 Dirección: Ciudad de México, México',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para cada sección
  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
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
}
