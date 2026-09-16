class Checkpoint {
  final String id;
  final String codigo;
  final String nombre;
  final double lat;
  final double lng;
  final double km;
  final int orden;
  final String rutaId;
  final String syncStatus;
  final bool esTerminal;

  const Checkpoint({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.km,
    required this.orden,
    required this.rutaId,
    this.syncStatus = 'OK',
    this.esTerminal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'lat': lat,
      'lng': lng,
      'km': km,
      'orden': orden,
      'ruta_id': rutaId,
      'sync_status': syncStatus,
    };
  }

  factory Checkpoint.fromMap(Map<String, dynamic> map) {
    final codigo = map['codigo'] as String;
    return Checkpoint(
      id: map['id'] as String,
      codigo: codigo,
      nombre: map['nombre'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      km: (map['km'] as num).toDouble(),
      orden: map['orden'] as int,
      rutaId: map['ruta_id'] as String,
      syncStatus: (map['sync_status'] as String?) ?? 'OK',
      esTerminal: codigo.startsWith('TER-'),
    );
  }
}
