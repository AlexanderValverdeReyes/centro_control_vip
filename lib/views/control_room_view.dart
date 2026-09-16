import 'package:flutter/material.dart';
import '../widgets/kanban_board.dart';
import '../widgets/radar_2d.dart';

class ControlRoomView extends StatelessWidget {
  const ControlRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildMetrics(),
          const SizedBox(height: 24),
          const Expanded(flex: 5, child: KanbanBoard()),
          const SizedBox(height: 24),
          const Expanded(flex: 3, child: Radar2D()),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _metricCard('Total Flota', '45', Colors.white, Icons.directions_bus),
        _metricCard('En Terminal', '12', const Color(0xFF0B3B6F), Icons.garage),
        _metricCard('En Tránsito Normal', '30', Colors.green, Icons.check_circle),
        _metricCard('En Observación', '3', const Color(0xFF8B0000), Icons.warning),
      ],
    );
  }

  Widget _metricCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        color: const Color(0xFF2C3035),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color.withOpacity(0.8)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
