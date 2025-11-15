import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  String? _estadoSeleccionado;

  // Método para crear una cita (CREATE)
  Future<void> _agregarCita() async {
    await _showCitaDialog(context, null);
  }

  // Método para leer citas (READ) - ya implementado en el StreamBuilder

  // Método para actualizar una cita (UPDATE)
  Future<void> _actualizarCita(String docId, Map<String, dynamic> citaActual) async {
    await _showCitaDialog(context, docId, citaActual: citaActual);
  }

  // Método para eliminar una cita (DELETE)
  Future<void> _eliminarCita(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('citas').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cita eliminada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al eliminar: $e')),
        );
      }
    }
  }

  // Método para seleccionar fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _fechaController.text = picked.toString().split(' ')[0];
      });
    }
  }

  // Método para seleccionar hora
  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _horaController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }


  // Diálogo para crear/editar citas
  Future<void> _showCitaDialog(
    BuildContext context,
    String? docId, {
    Map<String, dynamic>? citaActual,
  }) async {
    // Si estamos editando, llenamos los controladores con los valores actuales
    if (citaActual != null) {
      _motivoController.text = citaActual['motivo'] ?? '';
      _fechaController.text = citaActual['fecha'] ?? '';
      _horaController.text = citaActual['hora'] ?? '';
      _estadoSeleccionado = citaActual['estado']; // ✅ CAMBIO AQUÍ
    } else {
      _motivoController.clear();
      _fechaController.clear();
      _horaController.clear();
      _estadoSeleccionado = null; // ✅ CAMBIO AQUÍ
    }



    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Crear Cita' : 'Editar Cita'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  hintText: 'Seleccionar fecha',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  hintText: 'Seleccionar hora',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: _seleccionarHora,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: ['Pendiente', 'Confirmada', 'Cancelada', 'Completada']
                    .map((estado) => DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _estadoSeleccionado = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _guardarCita(docId);
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Guardar cita (crear o actualizar)
  Future<void> _guardarCita(String? docId) async {
  // Validación
  if (_motivoController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠ El motivo es obligatorio')),
    );
    return;
  }

  // Validar formato de fecha
  final fechaRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!fechaRegex.hasMatch(_fechaController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠ Formato de fecha inválido (YYYY-MM-DD)')),
    );
    return;
  }

  final citaData = {
      'motivo': _motivoController.text.trim(),
      'fecha': _fechaController.text.trim(),
      'hora': _horaController.text.trim(),
      'estado': _estadoSeleccionado ?? 'Pendiente',
      'idMedico': 'doc001',
      'idPaciente': 'user001',
      'timestamp': FieldValue.serverTimestamp(),
    };



    try {
      if (docId == null) {
        // Crear nueva cita
        final docRef = await _firestore.collection('citas').add(citaData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Cita creada con ID: ${docRef.id}')),
        );
      } else {
        // Actualizar cita existente
        await _firestore.collection('citas').doc(docId).update(citaData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cita actualizada correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e')),
      );
    }
  }

  // Menú contextual para cada cita
  Widget _buildCitaMenuItem(Map<String, dynamic> cita, String docId) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          _actualizarCita(docId, cita);
        } else if (value == 'delete') {
          _eliminarCita(docId);
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Modificar'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Citas Médicas')),
      body: StreamBuilder(
        stream: _firestore.collection('citas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay citas programadas'));
          }

          final citas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final citaDoc = citas[index];
              final cita = citaDoc.data();
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(
                    cita['motivo'] ?? 'Sin motivo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${cita['fecha'] ?? 'No especificada'}'),
                      Text('Hora: ${cita['hora'] ?? 'No especificada'}'), // ✅ Ya protegido
                      Text('Estado: ${cita['estado'] ?? 'Pendiente'}'), // ✅ Valor por defecto
                    ],
                  ),
                  trailing: _buildCitaMenuItem(cita, citaDoc.id),
                  onTap: () {
                    // Opcional: puedes agregar una acción al hacer tap en toda la lista
                    _actualizarCita(citaDoc.id, cita);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCita,
        child: const Icon(Icons.add),
      ),
    );
  }
}