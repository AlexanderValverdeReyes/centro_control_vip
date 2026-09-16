class Despacho {
  final String id;
  final String codigo;
  final String unidadId;
  final String conductorId;
  final String rutaId;
  final String andenId;
  final String salidaProg;
  final String salidaReal;
  final int desviacionMin;
  final String tipoServicio;
  final String sync; // OK, PENDING, FAIL
  final String uuid;
  final String ultimoCheckpointId;
  final double progresoRuta; // 0.0 a 1.0
  final String createdAt;
  final String sha256;

  // Campos adicionales en joins
  final String? unidadCodigo;
  final String? unidadPlaca;
  final String? conductorNombre;
  final String? rutaNombre;
  final String? andenNumero;

  const Despacho({
    required this.id,
    required this.codigo,
    required this.unidadId,
    required this.conductorId,
    required this.rutaId,
    required this.andenId,
    required this.salidaProg,
    required this.salidaReal,
    this.desviacionMin = 0,
    required this.tipoServicio,
    required this.sync,
    required this.uuid,
    required this.ultimoCheckpointId,
    this.progresoRuta = 0.0,
    required this.createdAt,
    required this.sha256,
    this.unidadCodigo,
    this.unidadPlaca,
    this.conductorNombre,
    this.rutaNombre,
    this.andenNumero,
  });

  String? get ultimoCheckpoint => ultimoCheckpointId.isNotEmpty ? ultimoCheckpointId : null;
  double? get progreso => progresoRuta;
  double? get velocidadActual => 82.0;
  String? get hashIntegridad => sha256;
  String? get andenNombre => andenNumero != null ? 'Andén $andenNumero' : andenId;
  String get estado {
    if (salidaReal.isEmpty) return 'EN_ESPERA';
    if (progresoRuta >= 1.0) return 'COMPLETADO';
    return 'EN_RUTA';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'unidad_id': unidadId,
      'conductor_id': conductorId,
      'ruta_id': rutaId,
      'anden_id': andenId,
      'salida_prog': salidaProg,
      'salida_real': salidaReal,
      'desviacion_min': desviacionMin,
      'tipo_servicio': tipoServicio,
      'sync': sync,
      'uuid': uuid,
      'ultimo_checkpoint_id': ultimoCheckpointId,
      'progreso_ruta': progresoRuta,
      'created_at': createdAt,
      'sha256': sha256,
    };
  }

  factory Despacho.fromMap(Map<String, dynamic> map) {
    return Despacho(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      unidadId: map['unidad_id'] as String,
      conductorId: map['conductor_id'] as String,
      rutaId: map['ruta_id'] as String,
      andenId: map['anden_id'] as String,
      salidaProg: (map['salida_prog'] as String?) ?? '',
      salidaReal: (map['salida_real'] as String?) ?? '',
      desviacionMin: (map['desviacion_min'] as int?) ?? 0,
      tipoServicio: (map['tipo_servicio'] as String?) ?? 'VIP EXPRESS',
      sync: (map['sync'] as String?) ?? 'PENDING',
      uuid: (map['uuid'] as String?) ?? '',
      ultimoCheckpointId: (map['ultimo_checkpoint_id'] as String?) ?? '',
      progresoRuta: (map['progreso_ruta'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as String,
      sha256: (map['sha256'] as String?) ?? '',
      unidadCodigo: map['unidad_codigo'] as String?,
      unidadPlaca: map['unidad_placa'] as String?,
      conductorNombre: map['conductor_nombre'] as String?,
      rutaNombre: map['ruta_nombre'] as String?,
      andenNumero: map['anden_numero'] as String?,
    );
  }

  Despacho copyWith({
    String? id,
    String? codigo,
    String? unidadId,
    String? conductorId,
    String? rutaId,
    String? andenId,
    String? salidaProg,
    String? salidaReal,
    int? desviacionMin,
    String? tipoServicio,
    String? sync,
    String? uuid,
    String? ultimoCheckpointId,
    double? progresoRuta,
    String? createdAt,
    String? sha256,
    String? unidadCodigo,
    String? unidadPlaca,
    String? conductorNombre,
    String? rutaNombre,
    String? andenNumero,
  }) {
    return Despacho(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      unidadId: unidadId ?? this.unidadId,
      conductorId: conductorId ?? this.conductorId,
      rutaId: rutaId ?? this.rutaId,
      andenId: andenId ?? this.andenId,
      salidaProg: salidaProg ?? this.salidaProg,
      salidaReal: salidaReal ?? this.salidaReal,
      desviacionMin: desviacionMin ?? this.desviacionMin,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      sync: sync ?? this.sync,
      uuid: uuid ?? this.uuid,
      ultimoCheckpointId: ultimoCheckpointId ?? this.ultimoCheckpointId,
      progresoRuta: progresoRuta ?? this.progresoRuta,
      createdAt: createdAt ?? this.createdAt,
      sha256: sha256 ?? this.sha256,
      unidadCodigo: unidadCodigo ?? this.unidadCodigo,
      unidadPlaca: unidadPlaca ?? this.unidadPlaca,
      conductorNombre: conductorNombre ?? this.conductorNombre,
      rutaNombre: rutaNombre ?? this.rutaNombre,
      andenNumero: andenNumero ?? this.andenNumero,
    );
  }
}
