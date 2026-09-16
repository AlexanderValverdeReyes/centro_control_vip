class Restriccion {
  final String id;
  final String codigo;
  final String motivo;
  final double km;
  final String severidad; // LEVE, MODERADA, CRITICA
  final bool activa;
  final String createdAt;
  final String syncStatus;

  const Restriccion({
    required this.id,
    required this.codigo,
    required this.motivo,
    required this.km,
    required this.severidad,
    required this.activa,
    required this.createdAt,
    this.syncStatus = 'OK',
  });

  String get tipo => 'RESTRICCIÓN $severidad ($codigo)';
  String get descripcion => motivo;
  String get tramoAfectado => 'KM ${km.toInt()} (Panamericana Sur)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'motivo': motivo,
      'km': km,
      'severidad': severidad,
      'activa': activa ? 1 : 0,
      'created_at': createdAt,
      'sync_status': syncStatus,
    };
  }

  factory Restriccion.fromMap(Map<String, dynamic> map) {
    return Restriccion(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      motivo: map['motivo'] as String,
      km: (map['km'] as num).toDouble(),
      severidad: (map['severidad'] as String?) ?? 'MODERADA',
      activa: (map['activa'] as int? ?? 1) == 1,
      createdAt: map['created_at'] as String,
      syncStatus: (map['sync_status'] as String?) ?? 'OK',
    );
  }
}
