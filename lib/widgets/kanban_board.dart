import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/bus.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final buses = context.watch<AppState>().buses;
    return Row(
      children: [
        _buildColumn('EN ANDÉN / SALIDA INMEDIATA', buses.where((b) => b.status == 'EN ANDÉN').toList()),
        const SizedBox(width: 16),
        _buildColumn('EN RUTA / TRÁNSITO FLUIDO', buses.where((b) => b.status == 'EN RUTA').toList()),
        const SizedBox(width: 16),
        _buildColumn('NOVEDADES / RETRASOS', buses.where((b) => b.status == 'NOVEDADES').toList(), isAlert: true),
      ],
    );
  }

  Widget _buildColumn(String title, List<Bus> buses, {bool isAlert = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isAlert ? const Color(0xFF8B0000).withOpacity(0.5) : Colors.white10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: isAlert ? const Color(0xFF8B0000) : const Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  final bus = buses[index];
                  return Card(
                    color: const Color(0xFF2C3035),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(bus.id, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace')),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: isAlert ? const Color(0xFF8B0000) : const Color(0xFF0B3B6F), borderRadius: BorderRadius.circular(4)),
                                child: Text(isAlert ? 'ALERTA' : 'OK', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(bus.route, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Operador: ${bus.operator}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timer, size: 14, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text(bus.eta, style: TextStyle(fontFamily: 'monospace', color: isAlert ? Colors.redAccent : Colors.white70)),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlert ? Colors.transparent : const Color(0xFF0B3B6F),
                                  side: isAlert ? const BorderSide(color: Colors.white54) : null,
                                  minimumSize: const Size(100, 36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                                ),
                                onPressed: () {},
                                child: Text(isAlert ? 'SEGUIMIENTO' : 'DESPACHAR AHORA', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
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
}
