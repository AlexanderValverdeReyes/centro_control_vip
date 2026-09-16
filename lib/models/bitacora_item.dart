class BitacoraItem {
  final String id;
  final String entidad;
  final String entidadId;
  final String accion;
  final String payload;
  final String sha256;
  final String createdAt;

  const BitacoraItem({
    required this.id,
    required this.entidad,
    required this.entidadId,
    required this.accion,
    required this.payload,
    required this.sha256,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entidad': entidad,
      'entidad_id': entidadId,
      'accion': accion,
      'payload': payload,
      'sha256': sha256,
      'created_at': createdAt,
    };
  }

  factory BitacoraItem.fromMap(Map<String, dynamic> map) {
    return BitacoraItem(
      id: map['id'] as String,
      entidad: map['entidad'] as String,
      entidadId: map['entidad_id'] as String,
      accion: map['accion'] as String,
      payload: map['payload'] as String,
      sha256: map['sha256'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
