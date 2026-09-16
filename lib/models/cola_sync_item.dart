class ColaSyncItem {
  final String id;
  final String entidad;
  final String entidadId;
  final String accion; // INSERT, UPDATE, DELETE
  final String payloadJson;
  final int intentos;
  final String proximoIntento;
  final String? ultimoError;
  final String createdAt;

  const ColaSyncItem({
    required this.id,
    required this.entidad,
    required this.entidadId,
    required this.accion,
    required this.payloadJson,
    this.intentos = 0,
    required this.proximoIntento,
    this.ultimoError,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entidad': entidad,
      'entidad_id': entidadId,
      'accion': accion,
      'payload_json': payloadJson,
      'intentos': intentos,
      'proximo_intento': proximoIntento,
      'ultimo_error': ultimoError,
      'created_at': createdAt,
    };
  }

  factory ColaSyncItem.fromMap(Map<String, dynamic> map) {
    return ColaSyncItem(
      id: map['id'] as String,
      entidad: map['entidad'] as String,
      entidadId: map['entidad_id'] as String,
      accion: map['accion'] as String,
      payloadJson: map['payload_json'] as String,
      intentos: (map['intentos'] as int?) ?? 0,
      proximoIntento: map['proximo_intento'] as String,
      ultimoError: map['ultimo_error'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
