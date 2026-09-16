class Ruta {
  final String id;
  final String codigo;
  final String nombre;
  final String corredor;
  final String origen;
  final String destino;
  final double distanciaKm;
  final int duracionMin;
  final String polyline; // JSON con lista de coordenadas
  final bool activa;
  final String syncStatus;

  const Ruta({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.corredor,
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.duracionMin,
    required this.polyline,
    this.activa = true,
    this.syncStatus = 'OK',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'corredor': corredor,
      'origen': origen,
      'destino': destino,
      'distancia_km': distanciaKm,
      'duracion_min': duracionMin,
      'polyline': polyline,
      'activa': activa ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory Ruta.fromMap(Map<String, dynamic> map) {
    return Ruta(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      corredor: map['corredor'] as String,
      origen: map['origen'] as String,
      destino: map['destino'] as String,
      distanciaKm: (map['distancia_km'] as num).toDouble(),
      duracionMin: map['duracion_min'] as int,
      polyline: (map['polyline'] as String?) ?? '[]',
      activa: (map['activa'] as int? ?? 1) == 1,
      syncStatus: (map['sync_status'] as String?) ?? 'OK',
    );
  }
}
