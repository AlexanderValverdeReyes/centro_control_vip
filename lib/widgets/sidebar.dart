import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/sync_provider.dart';
import 'despacho_modal.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final appProv = context.watch<AppProvider>();
    final syncProv = context.watch<SyncProvider>();

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(right: BorderSide(color: palette.outline, width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo VIP Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: palette.outline)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: palette.gold, width: 1.5),
                  ),
                  child: Icon(Icons.shield_rounded, color: palette.gold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTROL VIP',
                        style: context.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: palette.gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'DESPACHO INTERPROVINCIAL',
                        style: context.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: palette.textoSecundario,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menú de Navegación (5 Items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'OPERACIONES',
              style: context.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: palette.textoSecundario,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _navItem(
            context,
            index: 0,
            title: 'Sala de Control',
            icon: Icons.dashboard_rounded,
            isSelected: appProv.currentIndex == 0,
          ),
          _navItem(
            context,
            index: -1,
            title: 'Módulo de Despacho',
            icon: Icons.departure_board_rounded,
            isSelected: false,
            isAction: true,
            onAction: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const DespachoModal(),
              );
            },
          ),
          _navItem(
            context,
            index: 1,
            title: 'Monitoreo 2D',
            icon: Icons.radar_rounded,
            isSelected: appProv.currentIndex == 1,
          ),
          _navItem(
            context,
            index: 2,
            title: 'Registro de Salidas',
            icon: Icons.table_chart_rounded,
            isSelected: appProv.currentIndex == 2,
          ),
          _navItem(
            context,
            index: 3,
            title: 'Gestión de Flota',
            icon: Icons.commute_rounded,
            isSelected: appProv.currentIndex == 3,
          ),

          const Spacer(),

          // Indicador Inferior de MODO LOCAL SQLITE & SYNC
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storage_rounded, color: palette.exito, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'MODO LOCAL (SQLITE)',
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: palette.exito,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: syncProv.status == SyncStatus.ok
                            ? palette.exito
                            : (syncProv.status == SyncStatus.pending
                                ? palette.advertencia
                                : palette.peligro),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncProv.status == SyncStatus.ok
                            ? 'SYNC CLOUD OK'
                            : (syncProv.status == SyncStatus.pending
                                ? '${syncProv.pendingCount} PENDIENTES'
                                : 'ERROR EN SYNC'),
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: syncProv.status == SyncStatus.ok
                              ? palette.exito
                              : (syncProv.status == SyncStatus.pending
                                  ? palette.advertencia
                                  : palette.peligro),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => syncProv.forzarSincronizacion(),
                      child: Icon(Icons.sync_rounded, size: 16, color: palette.textoSecundario),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'MOTOR SQLITE WAL ACTIVO',
                  style: context.inter(
                    fontSize: 9,
                    color: palette.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool isSelected,
    bool isAction = false,
    VoidCallback? onAction,
  }) {
    final palette = context.palette;
    return InkWell(
      onTap: () {
        if (isAction && onAction != null) {
          onAction();
        } else {
          context.read<AppProvider>().setCurrentIndex(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: palette.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              icon,
              size: 18,
              color: isSelected ? palette.gold : palette.textoSecundario,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: context.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : palette.textoPrincipal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
