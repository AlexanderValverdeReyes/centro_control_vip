import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'control_room_view.dart';
import 'route_monitoring_view.dart';
import 'departure_log_view.dart';
import 'dispatch_modal.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, state),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildContent(state.currentMenuIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppState state) {
    return Container(
      width: 250,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text('CONTROL VIP', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _menuItem(context, 'Sala de Control', Icons.dashboard, 0, state.currentMenuIndex == 0),
          _menuItem(context, 'Módulo de Despacho', Icons.departure_board, -1, false, isAction: true), // Trigger modal directly
          _menuItem(context, 'Monitoreo 2D de Rutas', Icons.map, 1, state.currentMenuIndex == 1),
          _menuItem(context, 'Registro de Salidas', Icons.list_alt, 2, state.currentMenuIndex == 2),
          const Spacer(),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.storage, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('MODO LOCAL (SQLITE)', style: TextStyle(color: Colors.green, fontSize: 12, fontFamily: 'monospace')),
                ]),
                SizedBox(height: 8),
                Text('SYNC V2.4', style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon, int index, bool isSelected, {bool isAction = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFD4AF37) : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? const Color(0xFFD4AF37) : Colors.white, fontSize: 14)),
      selected: isSelected,
      onTap: () {
        if (isAction) {
          showDialog(context: context, builder: (_) => const DispatchModal());
        } else {
          context.read<AppState>().setMenuIndex(index);
        }
      },
      tileColor: isSelected ? const Color(0xFF0B3B6F).withOpacity(0.3) : null,
      hoverColor: const Color(0xFF2C3035),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text('TERMINAL ACTIVO: SEDE: TER-LIMA-JVICTORIA [Andenes: 01-12]', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            width: 250,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFF2C3035), borderRadius: BorderRadius.circular(4)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar unidad o código...',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white54, size: 20)
              ),
            ),
          ),
          const SizedBox(width: 24),
          const Text('22:15:30', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle, color: Colors.black),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
            ),
            onPressed: () => showDialog(context: context, builder: (_) => const DispatchModal()),
            label: const Text('NUEVO DESPACHO EXPRESS', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0: return const ControlRoomView();
      case 1: return const RouteMonitoringView();
      case 2: return const DepartureLogView();
      default: return const ControlRoomView();
    }
  }
}
