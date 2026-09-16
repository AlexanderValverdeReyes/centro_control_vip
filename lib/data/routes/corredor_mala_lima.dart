class WaypointCorredor {
  final String codigo;
  final String nombre;
  final double lat;
  final double lng;
  final double km;
  final int orden;
  final bool esTerminal;

  const WaypointCorredor({
    required this.codigo,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.km,
    required this.orden,
    this.esTerminal = false,
  });
}

/// Catálogo Oficial de Waypoints del Corredor Mala — Lima (Panamericana Sur Ruta 1S)
/// En orden geográfico de Sur a Norte (Mala hacia Lima)
class CorredorMalaLima {
  static const String rutaId = 'R-MALA-LIMA';
  static const String rutaNombre = 'MALA — LIMA (PANAMERICANA SUR 1S)';
  static const String corredorNombre = 'MALA — LIMA';

  static const List<WaypointCorredor> waypoints = [
    WaypointCorredor(
      codigo: 'TER-MALA',
      nombre: 'Terminal Terrestre de Mala',
      lat: -12.6580,
      lng: -76.6320,
      km: 90.0,
      orden: 1,
      esTerminal: true,
    ),
    WaypointCorredor(
      codigo: 'CHK-SAN-ANTONIO',
      nombre: 'Distrito de San Antonio (Cañete)',
      lat: -12.5930,
      lng: -76.6620,
      km: 80.0,
      orden: 2,
    ),
    WaypointCorredor(
      codigo: 'CHK-SAN-ANDRES',
      nombre: 'Distrito de San Andrés (Cañete)',
      lat: -12.5350,
      lng: -76.6900,
      km: 72.0,
      orden: 3,
    ),
    WaypointCorredor(
      codigo: 'CHK-CHILCA',
      nombre: 'Distrito de Chilca',
      lat: -12.4900,
      lng: -76.7200,
      km: 64.0,
      orden: 4,
    ),
    WaypointCorredor(
      codigo: 'CHK-PUCUSANA',
      nombre: 'Distrito de Pucusana',
      lat: -12.4400,
      lng: -76.7600,
      km: 58.0,
      orden: 5,
    ),
    WaypointCorredor(
      codigo: 'CHK-SM-MAR',
      nombre: 'Distrito de Santa María del Mar',
      lat: -12.4000,
      lng: -76.7750,
      km: 50.0,
      orden: 6,
    ),
    WaypointCorredor(
      codigo: 'CHK-SAN-BARTOLO',
      nombre: 'Distrito de San Bartolo',
      lat: -12.3800,
      lng: -76.7820,
      km: 46.0,
      orden: 7,
    ),
    WaypointCorredor(
      codigo: 'CHK-PUNTA-NEGRA',
      nombre: 'Distrito de Punta Negra',
      lat: -12.3600,
      lng: -76.7950,
      km: 44.0,
      orden: 8,
    ),
    WaypointCorredor(
      codigo: 'CHK-PUNTA-HERMOSA',
      nombre: 'Distrito de Punta Hermosa',
      lat: -12.3300,
      lng: -76.8150,
      km: 40.0,
      orden: 9,
    ),
    WaypointCorredor(
      codigo: 'CHK-LURIN',
      nombre: 'Distrito de Lurín',
      lat: -12.2700,
      lng: -76.8700,
      km: 25.0,
      orden: 10,
    ),
    WaypointCorredor(
      codigo: 'CHK-VES',
      nombre: 'Distrito de Villa El Salvador',
      lat: -12.2100,
      lng: -76.9300,
      km: 18.0,
      orden: 11,
    ),
    WaypointCorredor(
      codigo: 'CHK-VMT',
      nombre: 'Distrito de Villa María del Triunfo',
      lat: -12.1600,
      lng: -76.9550,
      km: 12.0,
      orden: 12,
    ),
    WaypointCorredor(
      codigo: 'CHK-SJM',
      nombre: 'Distrito de San Juan de Miraflores',
      lat: -12.1250,
      lng: -76.9750,
      km: 8.0,
      orden: 13,
    ),
    WaypointCorredor(
      codigo: 'TER-LIMA',
      nombre: 'Terminal Grau (La Victoria, Lima)',
      lat: -12.0620,
      lng: -77.0180,
      km: 0.0,
      orden: 14,
      esTerminal: true,
    ),
  ];
}
