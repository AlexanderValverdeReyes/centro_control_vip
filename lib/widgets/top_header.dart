import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import 'despacho_modal.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final appProv = context.watch<AppProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final syncProv = context.watch<SyncProvider>();

    return Container(
      height: 84, // Requisito estricto: 84px
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.outline, width: 1.0)),
      ),
      child: Row(
        children: [
          // Datos de terminal (Flexible para evitar overflow y truncar si el espacio es reducido)
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded, color: palette.gold, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'TERMINAL: ${AppConstants.terminalActivoId}',
                        style: context.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: palette.textoPrincipal,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: palette.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: palette.outline),
                      ),
                      child: Text(
                        'ANDENES: 01-12 VIP',
                        style: context.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: palette.gold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${AppConstants.terminalActivoNombre} • MALA — LIMA',
                        style: context.inter(
                          fontSize: 11,
                          color: palette.textoSecundario,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Buscador expandido (absorbe el espacio restante y se encoge según necesidad)
          Expanded(
            flex: 3,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.outline),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: palette.textoSecundario),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => appProv.setSearchQuery(val),
                      style: context.inter(fontSize: 12, color: palette.textoPrincipal),
                      decoration: InputDecoration(
                        hintText: 'Buscar unidad o código...',
                        hintStyle: context.inter(fontSize: 11, color: palette.textoSecundario),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reloj en tiempo real (fijo con ancho natural)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: palette.gold),
                const SizedBox(width: 6),
                Text(
                  appProv.currentTimeString,
                  style: context.mono(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: palette.gold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Indicador de Conectividad
          Tooltip(
            message: syncProv.status == SyncStatus.ok
                ? 'Conexión Estable • Sincronización OK'
                : (syncProv.status == SyncStatus.pending
                    ? 'Conexión Inestable / Pendientes en Cola'
                    : 'Error de Red / Reintento Manual'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.outline),
              ),
              child: Icon(
                syncProv.status == SyncStatus.ok
                    ? Icons.wifi_rounded
                    : (syncProv.status == SyncStatus.pending ? Icons.wifi_protected_setup : Icons.wifi_off_rounded),
                size: 18,
                color: syncProv.status == SyncStatus.ok
                    ? palette.exito
                    : (syncProv.status == SyncStatus.pending ? palette.advertencia : palette.peligro),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botón Toggle Claro / Oscuro
          Tooltip(
            message: themeProv.isDarkMode ? 'Cambiar a Modo Claro' : 'Cambiar a Modo Oscuro',
            child: InkWell(
              onTap: () => themeProv.toggleTheme(),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: palette.outline),
                ),
                child: Icon(
                  themeProv.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  size: 18,
                  color: themeProv.isDarkMode ? palette.gold : palette.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Botón Dorado Prominente NUEVO DESPACHO EXPRESS con ancho mínimo garantizado
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const DespachoModal(),
                );
              },
              icon: const Icon(Icons.add_circle_rounded, color: Colors.black, size: 18),
              label: Text(
                'NUEVO DESPACHO EXPRESS',
                style: context.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
