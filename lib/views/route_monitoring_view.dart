import 'package:flutter/material.dart';
import '../widgets/radar_2d.dart';

class RouteMonitoringView extends StatelessWidget {
  const RouteMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              _tab('PANAMERICANA NORTE', false),
              _tab('PANAMERICANA SUR', true), // Active
              _tab('CARRETERA CENTRAL', false),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF8B0000), borderRadius: BorderRadius.circular(4)),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('1 RESTRICCIÓN ACTIVA: CHK-SUR-110 (Mantenimiento de Vía. Retraso est. 15m)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                const Expanded(flex: 3, child: Radar2D()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildRightPanel()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildBottomMetrics(),
        ],
      ),
    );
  }

  Widget _tab(String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0B3B6F) : const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
      ),
      child: Text(title, style: TextStyle(color: active ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BUS-VIP-204', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          _infoRow('Velocidad GPS', '85 km/h'),
          _infoRow('ETA Destino', '14:30:00'),
          _infoRow('Geolocalización', '-12.043, -77.028'),
          const SizedBox(height: 24),
          
          const Text('Nivel de Combustible', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: 0.75, backgroundColor: Colors.white12, color: const Color(0xFF0B3B6F), minHeight: 8),
          const SizedBox(height: 24),
          
          const Text('Presión de Neumáticos', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: 0.9, backgroundColor: Colors.white12, color: Colors.green, minHeight: 8),
          
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.radar),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B3B6F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              onPressed: () {},
              label: const Text('COM RADIO MESH', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomMetrics() {
    return Row(
      children: [
        _metric('Velocidad Promedio Flota', '78 km/h'),
        _metric('Diagnóstico Mecánico Global', 'ÓPTIMO'),
        _metric('Eficiencia de Consumo', '12 km/gal'),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        color: const Color(0xFF2C3035),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
