import 'package:flutter/material.dart';

class DispatchModal extends StatefulWidget {
  const DispatchModal({super.key});

  @override
  State<DispatchModal> createState() => _DispatchModalState();
}

class _DispatchModalState extends State<DispatchModal> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 700,
        height: 650,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: const Color(0xFF0B3B6F),
              width: double.infinity,
              child: const Text('NUEVO DESPACHO EXPRESS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(primary: Color(0xFFD4AF37))
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 4) {
                      setState(() => _currentStep++);
                    } else {
                      Navigator.pop(context);
                      _showSuccessModal(context);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  steps: [
                    Step(
                      title: const Text('Selector de Ruta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                      content: _buildRuta(), 
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed
                    ),
                    Step(
                      title: const Text('Selector de Bus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                      content: _buildBus(), 
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed
                    ),
                    Step(
                      title: const Text('Operador de Turno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                      content: _buildOperador(), 
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed
                    ),
                    Step(
                      title: const Text('Asignación de Andén', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                      content: _buildAnden(), 
                      isActive: _currentStep >= 3,
                      state: _currentStep > 3 ? StepState.complete : StepState.indexed
                    ),
                    Step(
                      title: const Text('Hora Programada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                      content: _buildHora(), 
                      isActive: _currentStep >= 4,
                      state: _currentStep == 4 ? StepState.editing : StepState.indexed
                    ),
                  ],
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37), 
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            onPressed: details.onStepContinue,
                            child: Text(_currentStep == 4 ? 'CONFIRMAR DESPACHO Y REGISTRAR' : 'CONTINUAR PASO', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('VOLVER', style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuta() => DropdownButtonFormField<String>(
    decoration: const InputDecoration(filled: true, fillColor: Color(0xFF2C3035), border: OutlineInputBorder()),
    dropdownColor: const Color(0xFF2C3035),
    value: 'LIMA - AREQUIPA',
    items: ['LIMA - AREQUIPA', 'LIMA - TRUJILLO', 'LIMA - CHICLAYO'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: (_) {},
  );

  Widget _buildBus() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF2C3035), border: Border.all(color: const Color(0xFF0B3B6F)), borderRadius: BorderRadius.circular(4)),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('BUS-VIP-101', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16)),
        Text('ODOM: 45,000 KM | TANQUE: 95%', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
      ],
    ),
  );

  Widget _buildOperador() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF2C3035), borderRadius: BorderRadius.circular(4)),
    child: const Row(
      children: [
        CircleAvatar(backgroundColor: Color(0xFF0B3B6F), child: Icon(Icons.person, color: Colors.white)),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OP-629 | Juan Perez', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('ESTADO: DESCANSO OK', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        )
      ],
    ),
  );

  Widget _buildAnden() => Wrap(
    spacing: 12,
    children: [
      _andenBtn('ANDÉN 01\n(Ocupado)', const Color(0xFF8B0000), false),
      _andenBtn('ANDÉN 02\n(Disponible)', const Color(0xFF0B3B6F), true),
      _andenBtn('ANDÉN 03\n(Mantenimiento)', Colors.grey[700]!, false),
    ],
  );

  Widget _andenBtn(String text, Color color, bool active) {
    return ElevatedButton(
      onPressed: active ? () {} : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        disabledBackgroundColor: color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildHora() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF2C3035), borderRadius: BorderRadius.circular(4)),
    child: const Row(
      children: [
        Icon(Icons.schedule, color: Color(0xFFD4AF37)),
        SizedBox(width: 16),
        Text('SALIDA PROGRAMADA: 22:30:00', style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFD4AF37), width: 2)),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFFD4AF37), size: 100),
              const SizedBox(height: 24),
              const Text('¡DESPACHO ASIGNADO CON ÉXITO!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF2C3035), borderRadius: BorderRadius.circular(4)),
                child: const Column(
                  children: [
                    Text('Código de Despacho', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('DSP-202609-0941', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text('Unidad: BUS-VIP-101 | Corredor VIP: LIMA-AREQUIPA', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text('Andén: 02 | Operador: OP-629', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('TRANSACCIÓN LOCAL ASEGURADA (SQLITE ENGINE) - COMMIT OK', style: TextStyle(color: Colors.green, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('SALA DE CONTROL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print, color: Colors.black),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)
                    ),
                    onPressed: () => Navigator.pop(context),
                    label: const Text('IMPRIMIR TICKET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}
