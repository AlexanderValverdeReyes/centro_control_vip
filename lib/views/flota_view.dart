import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../core/theme.dart';
import '../models/conductor.dart';
import '../models/unidad.dart';
import '../providers/flota_provider.dart';
import '../widgets/conductor_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/unidad_card.dart';

class FlotaView extends StatefulWidget {
  const FlotaView({super.key});

  @override
  State<FlotaView> createState() => _FlotaViewState();
}

class _FlotaViewState extends State<FlotaView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final flota = context.watch<FlotaProvider>();

    final unidades = flota.unidadesFiltradas;
    final conductores = flota.conductoresFiltrados;

    final unidadesEnAnden = flota.unidades.where((u) => u.estado == 'enAnden').length;
    final unidadesEnRuta = flota.unidades.where((u) => u.estado == 'enRuta').length;
    final conductoresDescansados =
        flota.conductores.where((c) => c.estado == 'DESCANSADO').length;
    final licenciasPorVencer =
        flota.conductores.where((c) => c.licenciaPorVencer || c.licenciaVencida).length;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Métricas de Flota y Personal
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'FLOTA TOTAL VIP',
                  value: '${flota.unidades.length} UNIDADES',
                  subtitle: '$unidadesEnAnden en andén • $unidadesEnRuta en ruta',
                  icon: Icons.directions_bus_rounded,
                  accentColor: palette.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MetricCard(
                  title: 'CONDUCTORES REGISTRADOS',
                  value: '${flota.conductores.length} PILOTOS',
                  subtitle: '$conductoresDescansados disponibles para turno',
                  icon: Icons.badge_rounded,
                  accentColor: palette.exito,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MetricCard(
                  title: 'ALERTAS DE LICENCIA',
                  value: '$licenciasPorVencer CASOS',
                  subtitle: licenciasPorVencer == 0 ? 'Todas vigentes' : 'Requiere renovación',
                  icon: Icons.warning_amber_rounded,
                  accentColor: licenciasPorVencer > 0 ? palette.advertencia : palette.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Toolbar: Tabs, Buscador y Botones de Registro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.outline),
            ),
            child: Row(
              children: [
                // Tabs
                SizedBox(
                  width: 300,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: palette.gold,
                    indicatorWeight: 3,
                    labelColor: palette.primary,
                    unselectedLabelColor: palette.textoSecundario,
                    labelStyle: context.mono(fontSize: 11, fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_bus, size: 16),
                            const SizedBox(width: 8),
                            Text('UNIDADES (${flota.unidades.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people, size: 16),
                            const SizedBox(width: 8),
                            Text('CONDUCTORES (${flota.conductores.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Buscador
                Expanded(
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
                            onChanged: (val) => flota.setFiltroTexto(val),
                            style: context.inter(fontSize: 12, color: palette.textoPrincipal),
                            decoration: InputDecoration(
                              hintText: 'Buscar por código, placa, nombre o DNI...',
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
                const SizedBox(width: 14),

                // Botón Registrar según tab
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    final isTabUnidades = _tabController.index == 0;
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.add, size: 16, color: Colors.black),
                      label: Text(
                        isTabUnidades ? 'REGISTRAR UNIDAD' : 'REGISTRAR CONDUCTOR',
                        style: context.mono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      onPressed: () {
                        if (isTabUnidades) {
                          _mostrarModalNuevaUnidad(context);
                        } else {
                          _mostrarModalNuevoConductor(context);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Contenido de Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Unidades Grid
                unidades.isEmpty
                    ? _buildEmptyState(context, 'No se encontraron unidades con los filtros seleccionados')
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: unidades.length,
                        itemBuilder: (context, index) {
                          final u = unidades[index];
                          return UnidadCard(unidad: u);
                        },
                      ),

                // Tab 2: Conductores Grid
                conductores.isEmpty
                    ? _buildEmptyState(context, 'No se encontraron conductores con los filtros seleccionados')
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: conductores.length,
                        itemBuilder: (context, index) {
                          final c = conductores[index];
                          return ConductorCard(conductor: c);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String msg) {
    final palette = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: palette.textoSecundario.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Text(msg, style: context.inter(fontSize: 12, color: palette.textoSecundario)),
        ],
      ),
    );
  }

  void _mostrarModalNuevaUnidad(BuildContext context) {
    final palette = context.palette;
    final codigoCtrl = TextEditingController();
    final placaCtrl = TextEditingController();
    final marcaCtrl = TextEditingController(text: 'Marcopolo');
    final modeloCtrl = TextEditingController(text: 'Paradiso G8');
    final anioCtrl = TextEditingController(text: '2025');
    final capacidadCtrl = TextEditingController(text: '48');
    final psiCtrl = TextEditingController(text: '120.0');
    final kmCtrl = TextEditingController(text: '25000');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
              Row(
                children: [
                  Icon(Icons.directions_bus, color: palette.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'REGISTRAR NUEVA UNIDAD VIP',
                    style: context.mono(fontSize: 13, fontWeight: FontWeight.bold, color: palette.primary),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: palette.outline, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codigoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Código (BUS-VIP-NNN)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: context.mono(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: placaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Placa (ABC-123)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: context.mono(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: marcaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: modeloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: anioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: capacidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad Pasajeros',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: psiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Presión PSI (100-130)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: kmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Odómetro (Km)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('CANCELAR', style: context.mono(fontSize: 11)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final codigo = codigoCtrl.text.trim();
                      final placa = placaCtrl.text.trim();
                      if (codigo.isEmpty || placa.isEmpty) return;

                      final psi = double.tryParse(psiCtrl.text) ?? 120.0;
                      final km = double.tryParse(kmCtrl.text) ?? 0.0;
                      final anio = int.tryParse(anioCtrl.text) ?? 2025;
                      final cap = int.tryParse(capacidadCtrl.text) ?? 48;

                      final u = Unidad(
                        id: const Uuid().v4(),
                        codigo: codigo,
                        placa: placa,
                        marca: marcaCtrl.text.trim(),
                        modelo: modeloCtrl.text.trim(),
                        anio: anio,
                        chasis: 'CHASIS-$codigo',
                        motor: 'MOTOR-$codigo',
                        odometroKm: km.toInt(),
                        capacidadPasajeros: cap,
                        tanqueLitros: 350,
                        presionNominalPsi: psi.toInt(),
                        tipoServicio: 'EXPRESS VIP',
                        estado: 'enAnden',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        deletedAt: null,
                        sha256: '',
                        syncStatus: 'PENDING',
                      );

                      await context.read<FlotaProvider>().registrarUnidad(u);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'GUARDAR UNIDAD',
                      style: context.mono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarModalNuevoConductor(BuildContext context) {
    final palette = context.palette;
    final codigoCtrl = TextEditingController();
    final nombresCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    final dniCtrl = TextEditingController();
    final licenciaCtrl = TextEditingController();
    final categoriaCtrl = TextEditingController(text: 'A-IIIc');
    final descansoCtrl = TextEditingController(text: '12');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
              Row(
                children: [
                  Icon(Icons.badge, color: palette.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'REGISTRAR NUEVO CONDUCTOR VIP',
                    style: context.mono(fontSize: 13, fontWeight: FontWeight.bold, color: palette.primary),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: palette.outline, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codigoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Código (OP-NNN)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: context.mono(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: dniCtrl,
                      decoration: const InputDecoration(
                        labelText: 'DNI (8 dígitos)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: context.mono(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nombresCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombres',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: apellidosCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: licenciaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'N° Licencia',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: categoriaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Categoría (ej: A-IIIc)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descansoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Horas Descanso Acumuladas',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('CANCELAR', style: context.mono(fontSize: 11)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final codigo = codigoCtrl.text.trim();
                      final nombres = nombresCtrl.text.trim();
                      final apellidos = apellidosCtrl.text.trim();
                      final dni = dniCtrl.text.trim();
                      if (codigo.isEmpty || nombres.isEmpty || dni.isEmpty) return;

                      final c = Conductor(
                        id: const Uuid().v4(),
                        codigo: codigo,
                        nombres: nombres,
                        apellidos: apellidos,
                        dni: dni,
                        licenciaNumero: licenciaCtrl.text.trim(),
                        licenciaCategoria: categoriaCtrl.text.trim(),
                        licenciaVencimiento: '2028-12-31',
                        telefono: '999888777',
                        estado: 'DESCANSADO',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        deletedAt: null,
                        sha256: '',
                        syncStatus: 'PENDING',
                      );

                      await context.read<FlotaProvider>().registrarConductor(c);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'GUARDAR CONDUCTOR',
                      style: context.mono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
