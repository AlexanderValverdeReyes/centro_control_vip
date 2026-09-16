import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/routes/corredor_mala_lima.dart';
import '../models/despacho.dart';
import '../providers/despacho_provider.dart';
import '../providers/rastreo_provider.dart';
import '../widgets/checkpoint_button.dart';
import '../widgets/corredor_map.dart';

class MonitoreoRutasView extends StatefulWidget {
  const MonitoreoRutasView({super.key});

  @override
  State<MonitoreoRutasView> createState() => _MonitoreoRutasViewState();
}

class _MonitoreoRutasViewState extends State<MonitoreoRutasView> {
  String _selectedTab = 'MALA — LIMA';
  Despacho? _selectedDespacho;
  WaypointCorredor? _selectedWaypoint;

  final List<String> _tabs = [
    'MALA — LIMA',
    'LIMA — MALA',
    'CHINCHA — LIMA',
    'PISCO — LIMA',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rastreoProv = context.watch<RastreoProvider>();
    final despProv = context.watch<DespachoProvider>();

    final despachosEnRuta =
        despProv.despachos.where((d) => d.estado == 'EN_RUTA').toList();
    final restricciones = rastreoProv.restricciones;

    final bool isCorredorHabilitado =
        _selectedTab == 'MALA — LIMA' || _selectedTab == 'LIMA — MALA';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Tabs de Corredores y Botón de Reportar Paso
          Row(
            children: [
              // Tabs de selección de corredor
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tabs.map((tab) {
                      final isSelected = _selectedTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTab = tab;
                              _selectedDespacho = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? palette.primary : palette.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected ? palette.gold : palette.outline,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.alt_route_rounded,
                                  size: 15,
                                  color: isSelected ? palette.gold : palette.textoSecundario,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tab,
                                  style: context.mono(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : palette.textoPrincipal,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Botón Prominente: REPORTAR PASO (Fase 7)
              const CheckpointButton(),
            ],
          ),
          const SizedBox(height: 12),

          // Banner de Restricciones Activas si existen
          if (restricciones.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: palette.peligro.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.peligro.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: palette.peligro, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ALERTA VIAL ACTIVA: ${restricciones.first.tipo} en ${restricciones.first.tramoAfectado}. ${restricciones.first.descripcion}',
                      style: context.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.peligro,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Área Central: Mapa Vectorial o Estado Vacío Elegante
          Expanded(
            child: isCorredorHabilitado
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Lienzo Principal del Mapa Vectorial (Fase 7)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: palette.outline),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CorredorMap(
                              compact: false,
                              despachosActivos: despachosEnRuta,
                              ultimoCheckpointCodigo:
                                  rastreoProv.ultimoCheckpointReportadoCodigo,
                              selectedWaypoint: _selectedWaypoint,
                              onCheckpointSelected: (wp) {
                                setState(() {
                                  _selectedWaypoint = wp;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Panel Lateral de Telemetría (320px)
                      SizedBox(
                        width: 320,
                        child: _buildTelemetrySidebar(
                          context,
                          despachosEnRuta,
                          rastreoProv,
                        ),
                      ),
                    ],
                  )
                : _buildCorredorEnHabilitacion(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCorredorEnHabilitacion(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.outline),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: palette.outline, width: 2),
              ),
              child: Icon(
                Icons.construction_rounded,
                color: palette.gold,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Corredor en habilitación',
              style: context.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: palette.textoPrincipal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'El corredor ${_selectedTab} se encuentra en fase de calibración telemétrica.\nEl corredor oficial activo es exclusivamente Mala — Lima (Panamericana Sur 1S).',
              style: context.inter(
                fontSize: 12,
                color: palette.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _selectedTab = 'MALA — LIMA';
                });
              },
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(
                'VOLVER A MALA — LIMA',
                style: context.mono(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetrySidebar(
    BuildContext context,
    List<Despacho> despachosEnRuta,
    RastreoProvider rastreo,
  ) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: palette.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.sensors_rounded, color: palette.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'TELEMETRÍA EN VIVO',
                  style: context.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: palette.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.exito.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${despachosEnRuta.length} ACTIVOS',
                    style: context.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: palette.exito,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de Unidades en Tránsito
          Expanded(
            child: despachosEnRuta.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No hay unidades en tránsito en este momento.\nDespache una unidad para visualizar la telemetría.',
                        style: context.inter(
                          fontSize: 11,
                          color: palette.textoSecundario,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: despachosEnRuta.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final dsp = despachosEnRuta[index];
                      final isSelected = _selectedDespacho?.id == dsp.id;
                      final progreso = (dsp.progreso ?? 0.0).clamp(0.0, 1.0);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDespacho = dsp;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? palette.primary.withValues(alpha: 0.08)
                                : palette.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? palette.gold : palette.outline,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    dsp.unidadCodigo ?? 'VIP-BUS',
                                    style: context.mono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: palette.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      dsp.codigo,
                                      style: context.mono(
                                        fontSize: 9,
                                        color: palette.textoSecundario,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${(progreso * 100).toInt()}%',
                                      style: context.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: palette.gold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Piloto: ${dsp.conductorNombre ?? dsp.conductorId}',
                                style: context.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Último: ${dsp.ultimoCheckpoint ?? "MALA (0 km)"}',
                                      style: context.mono(
                                        fontSize: 9,
                                        color: palette.textoSecundario,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${dsp.velocidadActual?.toInt() ?? 80} km/h',
                                      style: context.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: palette.exito,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Mini Lista de los 14 Checkpoints para referencia rápida
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surfaceVariant,
              border: Border(top: BorderSide(color: palette.outline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '14 CHECKPOINTS',
                  style: context.mono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: palette.textoSecundario,
                  ),
                ),
                Text(
                  'Ruta 1S • 90.0 KM',
                  style: context.mono(
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
}
