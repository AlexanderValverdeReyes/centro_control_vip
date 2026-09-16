class Anden {
  final String id;
  final String numero;
  final String estado; // DISPONIBLE, OCUPADO, MANTENIMIENTO
  final String? despachoActualId;
  final String syncStatus;

  const Anden({
    required this.id,
    required this.numero,
    required this.estado,
    this.despachoActualId,
    this.syncStatus = 'OK',
  });

  bool get isDisponible => estado == 'DISPONIBLE';
  String get codigo => 'AND-$numero';
  String get nombre => 'Andén $numero';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'estado': estado,
      'despacho_actual_id': despachoActualId,
      'sync_status': syncStatus,
    };
  }

  factory Anden.fromMap(Map<String, dynamic> map) {
    return Anden(
      id: map['id'] as String,
      numero: map['numero'] as String,
      estado: (map['estado'] as String?) ?? 'DISPONIBLE',
      despachoActualId: map['despacho_actual_id'] as String?,
      syncStatus: (map['sync_status'] as String?) ?? 'OK',
    );
  }

  Anden copyWith({
    String? id,
    String? numero,
    String? estado,
    String? despachoActualId,
    String? syncStatus,
  }) {
    return Anden(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      estado: estado ?? this.estado,
      despachoActualId: despachoActualId ?? this.despachoActualId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
