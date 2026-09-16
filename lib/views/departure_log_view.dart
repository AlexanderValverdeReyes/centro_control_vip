import 'package:flutter/material.dart';

class DepartureLogView extends StatelessWidget {
  const DepartureLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMetrics(),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(child: _buildTable()),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        _metric('Despachos de Turno', '24'),
        _metric('Índice Puntualidad OTP', '98.5%'),
        _metric('Sync Telemetría Cloud', 'OK / ESTABLE'),
        _metric('Custodia SHA-256', 'FIRMADO'),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        color: const Color(0xFF2C3035),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar por ID o Unidad...',
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.search, color: Colors.white54)
            )
          )
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none)),
            dropdownColor: const Color(0xFF1E1E1E),
            value: 'Todas las Rutas',
            items: ['Todas las Rutas', 'LIMA-AREQUIPA', 'LIMA-TRUJILLO'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (_) {},
          )
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.download, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
          ),
          onPressed: () {},
          label: const Text('EXPORTAR A EXCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF2C3035)),
            dataRowMaxHeight: 60,
            columns: const [
              DataColumn(label: Text('ID Despacho', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Código Unidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Ruta Asignada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Operador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Andén', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Estado Sync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
            rows: [
              _buildRow('DSP-0941', 'BUS-VIP-101', 'LIMA - AREQUIPA', 'OP-629', '02', true),
              _buildRow('DSP-0942', 'BUS-VIP-102', 'LIMA - TRUJILLO', 'OP-112', '05', true),
              _buildRow('DSP-0943', 'BUS-VIP-103', 'LIMA - ICA', 'OP-992', '01', false),
              _buildRow('DSP-0944', 'BUS-VIP-204', 'LIMA - AREQUIPA', 'OP-331', '12', true),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String id, String unit, String route, String op, String anden, bool isSync) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(color: Colors.white, fontFamily: 'monospace'))),
      DataCell(Text(unit, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(route, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(op, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(anden, style: const TextStyle(color: Colors.white70))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: isSync ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
        child: Text(isSync ? 'SYNC OK' : 'PENDING', style: TextStyle(color: isSync ? Colors.green : Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
      )),
    ]);
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3B6F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF0B3B6F))
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, color: Colors.white70, size: 20),
          SizedBox(width: 8),
          Text('EXPEDIENTE SELECCIONADO: UUID-8F92-4B1C-A109 | FIRMA DIGITAL VÁLIDA', style: TextStyle(color: Colors.white, fontFamily: 'monospace', letterSpacing: 1.1)),
        ],
      ),
    );
  }
}
