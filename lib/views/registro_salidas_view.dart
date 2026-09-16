import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/despacho.dart';
import '../providers/despacho_provider.dart';
import '../widgets/metric_card.dart';

class RegistroSalidasView extends StatefulWidget {
  const RegistroSalidasView({super.key});

  @override
  State<RegistroSalidasView> createState() => _RegistroSalidasViewState();
}

class _RegistroSalidasViewState extends State<RegistroSalidasView> {
  String _filtroTexto = '';
  String? _hoveredId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final despProv = context.watch<DespachoProvider>();

    final todosDespachos = despProv.despachos;
    final filtrados = despProv.despachosFiltrados.where((d) {
      if (_filtroTexto.isEmpty) return true;
      final q = _filtroTexto.toLowerCase();
      return d.codigo.toLowerCase().contains(q) ||
          (d.unidadCodigo != null && d.unidadCodigo!.toLowerCase().contains(q)) ||
          (d.conductorNombre != null && d.conductorNombre!.toLowerCase().contains(q)) ||
          (d.rutaNombre != null && d.rutaNombre!.toLowerCase().contains(q));
    }).toList();

    // Métricas OTP
    final total = todosDespachos.length;
    final syncOk = todosDespachos.where((d) => d.sync == 'OK').length;
    final syncPending = todosDespachos.where((d) => d.sync == 'PENDING').length;
    final enRuta = todosDespachos.where((d) => d.estado == 'EN_RUTA').length;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Métricas superiores de Salidas
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'TOTAL DESPACHOS EMITIDOS',
                  value: '$total DESPACHOS',
                  subtitle: 'Base de datos SQLite local',
                  icon: Icons.receipt_long_rounded,
                  accentColor: palette.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'SINCRONIZADOS CLOUD',
                  value: '$syncOk REGISTROS',
                  subtitle: 'Confirmados con servidor central',
                  icon: Icons.cloud_done_rounded,
                  accentColor: palette.exito,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'PENDIENTES EN COLA OUTBOX',
                  value: '$syncPending POR SUBIR',
                  subtitle: 'Almacenamiento seguro offline-first',
                  icon: Icons.cloud_queue_rounded,
                  accentColor: syncPending > 0 ? palette.advertencia : palette.textoSecundario,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'UNIDADES EN TRÁNSITO',
                  value: '$enRuta EN RUTA 1S',
                  subtitle: 'Corredor Panamericana Sur',
                  icon: Icons.directions_bus_rounded,
                  accentColor: palette.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Barra de Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.outline),
            ),
            child: Row(
              children: [
                // Buscador por texto
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: palette.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: palette.outline),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 16, color: palette.textoSecundario),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() => _filtroTexto = val.trim());
                            },
                            style: context.inter(fontSize: 12, color: palette.textoPrincipal),
                            decoration: InputDecoration(
                              hintText: 'Filtrar por código, placa, unidad o conductor...',
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

                // Filtro por Estado Sync
                Text(
                  'SYNC:',
                  style: context.mono(fontSize: 10, fontWeight: FontWeight.bold, color: palette.textoSecundario),
                ),
                const SizedBox(width: 6),
                DropdownButton<String>(
                  value: despProv.filtroSync,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'OK', child: Text('OK')),
                    DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                    DropdownMenuItem(value: 'FAIL', child: Text('FAIL')),
                  ],
                  onChanged: (val) {
                    if (val != null) despProv.setFiltroSync(val);
                  },
                ),
                const SizedBox(width: 14),

                // Botón de refrescar datos
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Actualizar registros',
                  onPressed: () => despProv.cargarDatos(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Tabla de Alta Densidad (36px por fila)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.outline),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    // Header de la tabla (36px)
                    Container(
                      height: 36,
                      color: palette.surfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _buildHeaderCell(context, 'HORA PROG', flex: 2),
                          _buildHeaderCell(context, 'HORA REAL', flex: 2),
                          _buildHeaderCell(context, 'CÓDIGO DSP', flex: 3),
                          _buildHeaderCell(context, 'RUTA / CORREDOR', flex: 4),
                          _buildHeaderCell(context, 'UNIDAD', flex: 2),
                          _buildHeaderCell(context, 'CONDUCTOR', flex: 4),
                          _buildHeaderCell(context, 'ANDÉN', flex: 1, isCentered: true),
                          _buildHeaderCell(context, 'ESTADO', flex: 2, isCentered: true),
                          _buildHeaderCell(context, 'SYNC', flex: 2, isCentered: true),
                          _buildHeaderCell(context, 'AUDITORÍA', flex: 2, isCentered: true),
                        ],
                      ),
                    ),
                    Divider(color: palette.outline, height: 1),

                    // Filas de Datos (36px de altura exacta cada fila)
                    Expanded(
                      child: filtrados.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron registros de salida en el sistema local.',
                                style: context.inter(fontSize: 12, color: palette.textoSecundario),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtrados.length,
                              itemBuilder: (context, index) {
                                final dsp = filtrados[index];
                                final isEven = index % 2 == 0;
                                final isHovered = _hoveredId == dsp.id;

                                return MouseRegion(
                                  onEnter: (_) => setState(() => _hoveredId = dsp.id),
                                  onExit: (_) => setState(() => _hoveredId = null),
                                  child: GestureDetector(
                                    onDoubleTap: () => _mostrarModalAuditoria(context, dsp),
                                    child: Container(
                                      height: 36, // Requisito estricto: 36px por fila
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isHovered
                                            ? palette.primary.withValues(alpha: 0.07)
                                            : (isEven ? palette.surface : palette.surfaceVariant.withValues(alpha: 0.3)),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: palette.outline.withValues(alpha: 0.5),
                                            width: 0.8,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // HORA PROG
                                          _buildDataCell(
                                            context,
                                            dsp.salidaProg,
                                            flex: 2,
                                            isMono: true,
                                          ),
                                          // HORA REAL
                                          _buildDataCell(
                                            context,
                                            dsp.salidaReal.isNotEmpty ? dsp.salidaReal : '--:--:--',
                                            flex: 2,
                                            isMono: true,
                                            color: dsp.salidaReal.isNotEmpty ? palette.exito : palette.textoSecundario,
                                          ),
                                          // CÓDIGO DSP
                                          _buildDataCell(
                                            context,
                                            dsp.codigo,
                                            flex: 3,
                                            isMono: true,
                                            fontWeight: FontWeight.bold,
                                            color: palette.primary,
                                          ),
                                          // RUTA
                                          _buildDataCell(
                                            context,
                                            dsp.rutaNombre ?? dsp.rutaId,
                                            flex: 4,
                                          ),
                                          // UNIDAD
                                          _buildDataCell(
                                            context,
                                            dsp.unidadCodigo ?? dsp.unidadId,
                                            flex: 2,
                                            isMono: true,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          // CONDUCTOR
                                          _buildDataCell(
                                            context,
                                            dsp.conductorNombre ?? dsp.conductorId,
                                            flex: 4,
                                          ),
                                          // ANDÉN
                                          _buildDataCell(
                                            context,
                                            dsp.andenId.replaceAll('AND-', ''),
                                            flex: 1,
                                            isCentered: true,
                                            isMono: true,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          // ESTADO
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: _buildEstadoBadge(context, dsp.estado),
                                            ),
                                          ),
                                          // SYNC STATUS
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: _buildSyncBadge(context, dsp),
                                            ),
                                          ),
                                          // ACCIONES / AUDITORÍA
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: IconButton(
                                                icon: const Icon(Icons.security_rounded, size: 16),
                                                tooltip: 'Ver Integridad SHA-256',
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                color: palette.gold,
                                                onPressed: () => _mostrarModalAuditoria(context, dsp),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    String text, {
    required int flex,
    bool isCentered = false,
  }) {
    final palette = context.palette;
    return Expanded(
      flex: flex,
      child: Align(
        alignment: isCentered ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.mono(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: palette.textoSecundario,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(
    BuildContext context,
    String text, {
    required int flex,
    bool isCentered = false,
    bool isMono = false,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final palette = context.palette;
    return Expanded(
      flex: flex,
      child: Align(
        alignment: isCentered ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: isMono
              ? context.mono(
                  fontSize: 11,
                  fontWeight: fontWeight ?? FontWeight.normal,
                  color: color ?? palette.textoPrincipal,
                  letterSpacing: 0.2,
                )
              : context.inter(
                  fontSize: 11,
                  fontWeight: fontWeight ?? FontWeight.normal,
                  color: color ?? palette.textoPrincipal,
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(BuildContext context, String estado) {
    final palette = context.palette;
    Color bg;
    Color fg;
    String label = estado;

    switch (estado) {
      case 'EN_RUTA':
        bg = palette.exito.withValues(alpha: 0.15);
        fg = palette.exito;
        break;
      case 'EN_ESPERA':
        bg = palette.primary.withValues(alpha: 0.15);
        fg = palette.primary;
        break;
      case 'COMPLETADO':
        bg = palette.gold.withValues(alpha: 0.15);
        fg = palette.gold;
        break;
      default:
        bg = palette.surfaceVariant;
        fg = palette.textoSecundario;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: context.mono(fontSize: 8.5, fontWeight: FontWeight.bold, color: fg, letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget _buildSyncBadge(BuildContext context, Despacho dsp) {
    final palette = context.palette;
    final sync = dsp.sync;

    if (sync == 'OK') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: palette.exito.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.exito.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 10, color: palette.exito),
              const SizedBox(width: 4),
              Text('OK', style: context.mono(fontSize: 8.5, fontWeight: FontWeight.bold, color: palette.exito, letterSpacing: 0.2)),
            ],
          ),
        ),
      );
    } else if (sync == 'PENDING') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: palette.advertencia.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.advertencia.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 10, color: palette.advertencia),
              const SizedBox(width: 4),
              Text('OUTBOX', style: context.mono(fontSize: 8.5, fontWeight: FontWeight.bold, color: palette.advertencia, letterSpacing: 0.2)),
            ],
          ),
        ),
      );
    } else {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: InkWell(
          onTap: () {
            context.read<DespachoProvider>().reintentarSync(dsp.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: palette.peligro.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: palette.peligro.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 10, color: palette.peligro),
                const SizedBox(width: 4),
                Text('REINTENTAR', style: context.mono(fontSize: 8.5, fontWeight: FontWeight.bold, color: palette.peligro, letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _mostrarModalAuditoria(BuildContext context, Despacho dsp) {
    final palette = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: palette.gold, width: 1.2),
        ),
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: palette.gold, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'AUDITORÍA DE REGISTRO DE DESPACHO',
                    style: context.mono(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: palette.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: palette.outline, height: 1),
              const SizedBox(height: 14),
              _buildAuditRow(context, 'UUID Transaccional:', dsp.id),
              _buildAuditRow(context, 'Código Despacho:', dsp.codigo),
              _buildAuditRow(context, 'Ruta Oficial:', dsp.rutaNombre ?? dsp.rutaId),
              _buildAuditRow(context, 'Unidad Asignada:', dsp.unidadCodigo ?? dsp.unidadId),
              _buildAuditRow(context, 'Operador Asignado:', dsp.conductorNombre ?? dsp.conductorId),
              _buildAuditRow(context, 'Salida Programada:', dsp.salidaProg),
              _buildAuditRow(context, 'Salida Efectiva:', dsp.salidaReal.isNotEmpty ? dsp.salidaReal : 'Pendiente'),
              _buildAuditRow(context, 'Estado Operativo:', dsp.estado),
              _buildAuditRow(context, 'Estado Sincronización:', dsp.sync),
              const SizedBox(height: 12),
              Text(
                'SELLO CRIPTOGRÁFICO DE INTEGRIDAD (SHA-256):',
                style: context.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: palette.textoSecundario,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: palette.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        dsp.hashIntegridad ?? 'SIN_HASH',
                        style: context.mono(
                          fontSize: 10,
                          color: palette.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 14),
                      tooltip: 'Copiar Hash',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: dsp.hashIntegridad ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hash copiado al portapapeles')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('CERRAR', style: context.mono(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditRow(BuildContext context, String label, String value) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: context.inter(fontSize: 11, color: palette.textoSecundario)),
          ),
          Expanded(
            child: Text(
              value,
              style: context.mono(fontSize: 11, fontWeight: FontWeight.w600, color: palette.textoPrincipal),
            ),
          ),
        ],
      ),
    );
  }
}
