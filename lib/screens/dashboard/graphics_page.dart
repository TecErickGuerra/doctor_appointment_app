import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficas de Citas'),
        backgroundColor: const Color(0xFF00A8A8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gráfica de Citas por Mes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citas por Mes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, int>>(
                      future: _getAppointmentsByMonth(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay datos disponibles'),
                          );
                        }

                        return SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              barGroups: _createBarGroups(snapshot.data!),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Gráfica de Citas por Estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citas por Estado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, int>>(
                      future: _getAppointmentsByStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No hay datos disponibles'),
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: _createPieSections(snapshot.data!),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLegend(snapshot.data!),
                          ],
                        );
                      },
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

  // Métodos para obtener datos de Firebase
  Future<Map<String, int>> _getAppointmentsByMonth() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('fecha', isGreaterThan: '2024-01-01')
        .get();

    final Map<String, int> monthlyData = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fecha = data['fecha'] as String? ?? '2024-01-01';
      
      // Extraer año y mes del formato YYYY-MM-DD
      final parts = fecha.split('-');
      if (parts.length >= 2) {
        final monthKey = '${parts[0]}-${parts[1]}';
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
      }
    }
    
    return monthlyData;
  }

  Future<Map<String, int>> _getAppointmentsByStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('citas')
        .get();

    final Map<String, int> statusData = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['estado'] ?? 'Pendiente';
      statusData[status] = (statusData[status] ?? 0) + 1;
    }
    
    return statusData;
  }

  // Métodos auxiliares para gráficas
  List<BarChartGroupData> _createBarGroups(Map<String, int> data) {
    int index = 0;
    return data.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: const Color(0xFF00A8A8),
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _createPieSections(Map<String, int> data) {
    final total = data.values.fold(0, (sum, value) => sum + value);
    
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: _getStatusColor(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, int> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getStatusColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_getStatusLabel(entry.key)}: ${entry.value}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Métodos de colores y etiquetas
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completada': return Colors.green;
      case 'Cancelada': return Colors.red;
      case 'Pendiente': return Colors.orange;
      case 'Confirmada': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Completada': return 'Completadas';
      case 'Cancelada': return 'Canceladas';
      case 'Pendiente': return 'Pendientes';
      case 'Confirmada': return 'Confirmadas';
      default: return 'Desconocido';
    }
  }
}