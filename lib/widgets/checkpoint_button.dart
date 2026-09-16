import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/routes/corredor_mala_lima.dart';
import '../providers/despacho_provider.dart';
import '../providers/rastreo_provider.dart';

class CheckpointButton extends StatelessWidget {
  const CheckpointButton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.gold,
        foregroundColor: Colors.black,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: const Icon(Icons.add_location_alt_rounded, size: 18, color: Colors.black),
      label: Text(
        'REPORTAR PASO',
        style: context.mono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
      onPressed: () => _mostrarDialogoReporte(context),
    );
  }

  void _mostrarDialogoReporte(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _DialogoReporteCheckpoint(),
    );
  }
}

class _DialogoReporteCheckpoint extends StatefulWidget {
  const _DialogoReporteCheckpoint();

  @override
  State<_DialogoReporteCheckpoint> createState() =>
      _DialogoReporteCheckpointState();
}

class _DialogoReporteCheckpointState extends State<_DialogoReporteCheckpoint> {
  String? _despachoIdSeleccionado;
  String _checkpointCodigoSeleccionado = CorredorMalaLima.waypoints.first.codigo;
  String _origen = 'MANUAL';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final dspProvider = context.read<DespachoProvider>();
    final activos = dspProvider.despachos.where((d) => d.estado == 'EN_RUTA').toList();
    if (activos.isNotEmpty) {
      _despachoIdSeleccionado = activos.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dspProvider = context.watch<DespachoProvider>();
    final despachosEnRuta =
        dspProvider.despachos.where((d) => d.estado == 'EN_RUTA').toList();

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: palette.outline),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: palette.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_location_alt_rounded,
                      color: palette.gold, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REPORTAR PASO POR CHECKPOINT',
                      style: context.mono(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: palette.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Actualización de telemetría en el Corredor Mala — Lima',
                      style: context.inter(
                        fontSize: 11,
                        color: palette.textoSecundario,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: palette.outline, height: 1),
            const SizedBox(height: 18),

            if (despachosEnRuta.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.advertencia.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: palette.advertencia.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: palette.advertencia, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No hay unidades con estado "EN_RUTA" actualmente. Despache una unidad desde la Sala de Control.',
                        style: context.inter(
                          fontSize: 12,
                          color: palette.textoPrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CERRAR'),
                ),
              ),
            ] else ...[
              // Selección de Despacho
              Text(
                'DESPACHO ACTIVO',
                style: context.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: palette.textoSecundario,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _despachoIdSeleccionado,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: despachosEnRuta.map((d) {
                  return DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(
                      '${d.codigo} • ${d.unidadCodigo ?? "VIP"} (${d.rutaNombre ?? "MALA - LIMA"})',
                      style: context.mono(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _despachoIdSeleccionado = val;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Selección de Checkpoint de la lista oficial de 14
              Text(
                'CHECKPOINT OFICIAL (14 PUNTOS CORREDOR 1S)',
                style: context.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: palette.textoSecundario,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _checkpointCodigoSeleccionado,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: CorredorMalaLima.waypoints.map((wp) {
                  return DropdownMenuItem<String>(
                    value: wp.codigo,
                    child: Text(
                      '[${wp.codigo}] ${wp.nombre} (KM ${wp.km.toInt()})',
                      style: context.mono(
                        fontSize: 11,
                        color: wp.esTerminal ? palette.gold : palette.textoPrincipal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _checkpointCodigoSeleccionado = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Origen del reporte
              Text(
                'ORIGEN DEL REGISTRO',
                style: context.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: palette.textoSecundario,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: ['MANUAL', 'RFID', 'GPS'].map((tipo) {
                  final isSelected = _origen == tipo;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tipo, style: context.mono(fontSize: 11)),
                      selected: isSelected,
                      selectedColor: palette.primary.withValues(alpha: 0.15),
                      onSelected: (_) {
                        setState(() {
                          _origen = tipo;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('CANCELAR', style: context.mono(fontSize: 11)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _isSubmitting || _despachoIdSeleccionado == null
                        ? null
                        : () async {
                            setState(() {
                              _isSubmitting = true;
                            });

                            final rastreo = context.read<RastreoProvider>();
                            final despachos = context.read<DespachoProvider>();

                            await rastreo.reportarPaso(
                              despachoId: _despachoIdSeleccionado!,
                              checkpointCodigo: _checkpointCodigoSeleccionado,
                              origen: _origen,
                            );

                            await despachos.cargarDatos();

                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Paso registrado correctamente en $_checkpointCodigoSeleccionado',
                                    style: const TextStyle(fontFamily: 'monospace'),
                                  ),
                                  backgroundColor: palette.exito,
                                ),
                              );
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'CONFIRMAR PASO',
                            style: context.mono(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
