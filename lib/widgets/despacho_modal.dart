import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/anden.dart';
import '../models/conductor.dart';
import '../models/unidad.dart';
import '../providers/despacho_provider.dart';
import '../providers/flota_provider.dart';
import 'success_modal.dart';

class DespachoModal extends StatefulWidget {
  const DespachoModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DespachoModal(),
    );
  }

  @override
  State<DespachoModal> createState() => _DespachoModalState();
}

class _DespachoModalState extends State<DespachoModal> {
  int _currentStep = 0;

  String _rutaId = 'R-MALA-LIMA';
  String _rutaNombre = 'MALA — LIMA (PANAMERICANA SUR 1S)';
  Unidad? _selectedUnidad;
  Conductor? _selectedConductor;
  String? _selectedAndenId;
  String _tipoServicio = 'EXPRESS_VIP';
  late TimeOfDay _horaSalida;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().add(const Duration(minutes: 20));
    _horaSalida = TimeOfDay(hour: now.hour, minute: now.minute);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flota = context.read<FlotaProvider>();
      final despacho = context.read<DespachoProvider>();

      if (flota.unidadesDisponiblesParaDespacho.isNotEmpty) {
        setState(() {
          _selectedUnidad = flota.unidadesDisponiblesParaDespacho.first;
        });
      }
      if (flota.conductoresDisponiblesParaDespacho.isNotEmpty) {
        setState(() {
          _selectedConductor = flota.conductoresDisponiblesParaDespacho.first;
        });
      }
      if (despacho.andenesDisponibles.isNotEmpty) {
        setState(() {
          _selectedAndenId = despacho.andenesDisponibles.first.id;
        });
      }
    });
  }

  String _formattedTime() {
    final h = _horaSalida.hour.toString().padLeft(2, '0');
    final m = _horaSalida.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final flota = context.watch<FlotaProvider>();
    final despacho = context.watch<DespachoProvider>();

    final unidadesDisponibles = flota.unidadesDisponiblesParaDespacho;
    final conductoresDisponibles = flota.conductoresDisponiblesParaDespacho;
    final andenesDisponibles = despacho.andenesDisponibles;

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: palette.outline),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        width: 780,
        height: 620,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.departure_board_rounded, color: palette.gold, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NUEVO DESPACHO EXPRESS VIP',
                        style: context.mono(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Corredor Panamericana Sur Ruta 1S • Despacho Oficial',
                        style: context.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: palette.gold),

            // Stepper Content
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: palette.primary,
                    secondary: palette.gold,
                  ),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  elevation: 0,
                  controlsBuilder: (context, details) => const SizedBox.shrink(),
                  onStepTapped: (step) {
                    if (step < _currentStep) {
                      setState(() => _currentStep = step);
                    }
                  },
                  steps: [
                    // Paso 1: Ruta
                    Step(
                      title: Text('Ruta', style: context.mono(fontSize: 10)),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: _buildStep1Ruta(context),
                    ),
                    // Paso 2: Unidad
                    Step(
                      title: Text('Unidad', style: context.mono(fontSize: 10)),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                      content: _buildStep2Unidad(context, unidadesDisponibles),
                    ),
                    // Paso 3: Conductor
                    Step(
                      title: Text('Conductor', style: context.mono(fontSize: 10)),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                      content: _buildStep3Conductor(context, conductoresDisponibles),
                    ),
                    // Paso 4: Andén
                    Step(
                      title: Text('Andén', style: context.mono(fontSize: 10)),
                      isActive: _currentStep >= 3,
                      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                      content: _buildStep4Anden(context, andenesDisponibles),
                    ),
                    // Paso 5: Confirmación
                    Step(
                      title: Text('Confirmar', style: context.mono(fontSize: 10)),
                      isActive: _currentStep >= 4,
                      state: _currentStep == 4 ? StepState.editing : StepState.indexed,
                      content: _buildStep5Confirmar(context, andenesDisponibles),
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: palette.outline, height: 1),

            // Modal Footer Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      child: Text('ANTERIOR', style: context.mono(fontSize: 11)),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('CANCELAR', style: context.mono(fontSize: 11)),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep < 4)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_validateCurrentStep()) {
                          setState(() => _currentStep++);
                        }
                      },
                      child: Row(
                        children: [
                          Text('SIGUIENTE',
                              style: context.mono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios, size: 12),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _isSubmitting ? null : _ejecutarDespacho,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'CONFIRMAR Y EMITIR',
                                  style: context.mono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _rutaId.isNotEmpty;
      case 1:
        if (_selectedUnidad == null) {
          _showError('Debe seleccionar una unidad disponible');
          return false;
        }
        if (!_selectedUnidad!.presionNeumaticosValida) {
          _showError('La unidad tiene presión de neumáticos fuera del rango permitido (100-130 PSI)');
          return false;
        }
        return true;
      case 2:
        if (_selectedConductor == null) {
          _showError('Debe seleccionar un conductor descansado');
          return false;
        }
        if (_selectedConductor!.licenciaVencida) {
          _showError('El conductor seleccionado tiene la licencia de conducir vencida');
          return false;
        }
        return true;
      case 3:
        if (_selectedAndenId == null) {
          _showError('Debe seleccionar un andén de embarque');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'monospace')),
        backgroundColor: context.palette.peligro,
      ),
    );
  }

  Future<void> _ejecutarDespacho() async {
    if (_selectedUnidad == null || _selectedConductor == null || _selectedAndenId == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<DespachoProvider>();
      final despacho = await provider.registrarDespacho(
        unidadId: _selectedUnidad!.id,
        conductorId: _selectedConductor!.id,
        rutaId: _rutaId,
        andenId: _selectedAndenId!,
        salidaProg: _formattedTime(),
        tipoServicio: _tipoServicio,
      );

      final flota = context.read<FlotaProvider>();
      await flota.cargarFlota();

      if (mounted) {
        Navigator.of(context).pop();
        SuccessModal.show(context, despacho);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError('Error al procesar despacho atómico: $e');
    }
  }

  Widget _buildStep1Ruta(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECCIÓN DE CORREDOR INTERPROVINCIAL',
          style: context.mono(fontSize: 12, fontWeight: FontWeight.bold, color: palette.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'El Corredor Oficial activo es la Panamericana Sur Ruta 1S entre Mala y Lima.',
          style: context.inter(fontSize: 12, color: palette.textoSecundario),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: RadioListTile<String>(
            value: 'R-MALA-LIMA',
            groupValue: _rutaId,
            activeColor: palette.gold,
            tileColor: Colors.transparent,
            selectedTileColor: palette.primary.withValues(alpha: 0.08),
            selected: _rutaId == 'R-MALA-LIMA',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: _rutaId == 'R-MALA-LIMA' ? palette.gold : palette.outline,
              ),
            ),
            title: Text(
              'MALA — LIMA (PANAMERICANA SUR 1S)',
              style: context.mono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '90.0 KM • 14 Checkpoints • Tiempo Estimado: 95 min',
              style: context.inter(fontSize: 11, color: palette.textoSecundario),
            ),
            onChanged: (val) {
              setState(() {
                _rutaId = val!;
                _rutaNombre = 'MALA — LIMA (PANAMERICANA SUR 1S)';
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: RadioListTile<String>(
            value: 'R-LIMA-MALA',
            groupValue: _rutaId,
            activeColor: palette.gold,
            tileColor: Colors.transparent,
            selectedTileColor: palette.primary.withValues(alpha: 0.08),
            selected: _rutaId == 'R-LIMA-MALA',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: _rutaId == 'R-LIMA-MALA' ? palette.gold : palette.outline,
              ),
            ),
            title: Text(
              'LIMA — MALA (RETORNO SUR)',
              style: context.mono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '90.0 KM • 14 Checkpoints • Tiempo Estimado: 95 min',
              style: context.inter(fontSize: 11, color: palette.textoSecundario),
            ),
            onChanged: (val) {
              setState(() {
                _rutaId = val!;
                _rutaNombre = 'LIMA — MALA (RETORNO SUR)';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Unidad(BuildContext context, List<Unidad> unidadesDisponibles) {
    final palette = context.palette;
    if (unidadesDisponibles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.advertencia.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No hay unidades disponibles con estado "enAnden". Verifique el módulo de Flota.',
          style: context.inter(fontSize: 12, color: palette.textoPrincipal),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECCIONAR UNIDAD DISPONIBLE (EN ANDÉN)',
          style: context.mono(fontSize: 12, fontWeight: FontWeight.bold, color: palette.primary),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            itemCount: unidadesDisponibles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final u = unidadesDisponibles[index];
              final isSelected = _selectedUnidad?.id == u.id;
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? palette.primary.withValues(alpha: 0.08) : palette.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? palette.primary : palette.outline,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: ListTile(
                    dense: true,
                    tileColor: Colors.transparent,
                    selectedTileColor: Colors.transparent,
                    selected: isSelected,
                    textColor: palette.textoPrincipal,
                    iconColor: isSelected ? palette.primary : palette.textoSecundario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    leading: Icon(
                      Icons.directions_bus,
                      color: isSelected ? palette.primary : palette.textoSecundario,
                    ),
                    title: Row(
                      children: [
                        Text(u.codigo, style: context.mono(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(u.placa, style: context.mono(fontSize: 11, color: palette.textoSecundario)),
                        const Spacer(),
                        Text(
                          '${u.presionNeumaticosPsi.toInt()} PSI',
                          style: context.mono(
                            fontSize: 11,
                            color: u.presionNeumaticosValida ? palette.exito : palette.peligro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${u.marca} ${u.modelo} • Cap: ${u.capacidadPasajeros} pas.'),
                    trailing: Radio<String>(
                      value: u.id,
                      groupValue: _selectedUnidad?.id,
                      onChanged: (_) {
                        setState(() => _selectedUnidad = u);
                      },
                    ),
                    onTap: () {
                      setState(() => _selectedUnidad = u);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Conductor(BuildContext context, List<Conductor> conductoresDisponibles) {
    final palette = context.palette;
    if (conductoresDisponibles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.advertencia.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No hay conductores disponibles con estado "DESCANSADO" y licencia vigente.',
          style: context.inter(fontSize: 12, color: palette.textoPrincipal),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECCIONAR CONDUCTOR ASIGNADO (ESTADO DESCANSADO)',
          style: context.mono(fontSize: 12, fontWeight: FontWeight.bold, color: palette.primary),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            itemCount: conductoresDisponibles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = conductoresDisponibles[index];
              final isSelected = _selectedConductor?.id == c.id;
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? palette.primary.withValues(alpha: 0.08) : palette.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? palette.primary : palette.outline,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: ListTile(
                    dense: true,
                    tileColor: Colors.transparent,
                    selectedTileColor: Colors.transparent,
                    selected: isSelected,
                    textColor: palette.textoPrincipal,
                    iconColor: isSelected ? palette.primary : palette.textoSecundario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    leading: Icon(
                      Icons.badge,
                      color: isSelected ? palette.primary : palette.textoSecundario,
                    ),
                    title: Row(
                      children: [
                        Text(c.codigo, style: context.mono(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            c.nombreCompleto,
                            style: context.inter(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Lic. ${c.licenciaCategoria}', style: context.mono(fontSize: 11)),
                      ],
                    ),
                    subtitle: Text('Estado: ${c.estado} • DNI: ${c.dni}'),
                    trailing: Radio<String>(
                      value: c.id,
                      groupValue: _selectedConductor?.id,
                      onChanged: (_) {
                        setState(() => _selectedConductor = c);
                      },
                    ),
                    onTap: () {
                      setState(() => _selectedConductor = c);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Anden(BuildContext context, List<Anden> andenesDisponibles) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANDÉN DE EMBARQUE Y TIPO DE SERVICIO',
          style: context.mono(fontSize: 12, fontWeight: FontWeight.bold, color: palette.primary),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ANDÉN', style: context.mono(fontSize: 10, color: palette.textoSecundario)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedAndenId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    items: andenesDisponibles.map((a) {
                      return DropdownMenuItem<String>(
                        value: a.id,
                        child: Text(a.numero, style: context.mono(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedAndenId = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIPO DE SERVICIO', style: context.mono(fontSize: 10, color: palette.textoSecundario)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _tipoServicio,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EXPRESS_VIP', child: Text('EXPRESS VIP')),
                      DropdownMenuItem(value: 'DIRECTO_PANAMERICANA', child: Text('DIRECTO PANAMERICANA')),
                      DropdownMenuItem(value: 'REGULAR', child: Text('REGULAR INTERPROVINCIAL')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _tipoServicio = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('HORA DE SALIDA PROGRAMADA', style: context.mono(fontSize: 10, color: palette.textoSecundario)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.outline),
              ),
              child: Text(
                _formattedTime(),
                style: context.mono(fontSize: 16, fontWeight: FontWeight.bold, color: palette.primary),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time, size: 16),
              label: Text('MODIFICAR HORA', style: context.mono(fontSize: 11)),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _horaSalida,
                );
                if (picked != null) {
                  setState(() => _horaSalida = picked);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5Confirmar(BuildContext context, List<Anden> andenesDisponibles) {
    final palette = context.palette;
    final andenObj = andenesDisponibles.where((a) => a.id == _selectedAndenId).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.gold, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: palette.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'RESUMEN Y VALIDACIÓN DE INTEGRIDAD',
                style: context.mono(fontSize: 12, fontWeight: FontWeight.bold, color: palette.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(context, 'Corredor Oficial:', _rutaNombre),
          _buildSummaryRow(
              context,
              'Unidad Asignada:',
              '${_selectedUnidad?.codigo} (${_selectedUnidad?.placa}) • ${_selectedUnidad?.presionNeumaticosPsi.toInt()} PSI'),
          _buildSummaryRow(
              context,
              'Conductor Oficial:',
              '${_selectedConductor?.codigo} - ${_selectedConductor?.nombreCompleto} (Lic: ${_selectedConductor?.licenciaCategoria})'),
          _buildSummaryRow(
              context,
              'Andén / Embarque:',
              andenObj != null
                  ? '${andenObj.codigo} - ${andenObj.nombre}'
                  : (_selectedAndenId ?? 'No seleccionado')),
          _buildSummaryRow(context, 'Tipo de Servicio:', _tipoServicio),
          _buildSummaryRow(context, 'Salida Programada:', _formattedTime()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: palette.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 14, color: palette.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Se calculará el hash criptográfico SHA-256 en la transacción atómica de SQLite.',
                    style: context.mono(fontSize: 10, color: palette.textoSecundario),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: context.inter(fontSize: 11, color: palette.textoSecundario)),
          ),
          Expanded(
            child: Text(
              value,
              style: context.mono(fontSize: 11, fontWeight: FontWeight.bold, color: palette.textoPrincipal),
            ),
          ),
        ],
      ),
    );
  }
}
