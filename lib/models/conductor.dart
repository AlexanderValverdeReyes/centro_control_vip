class Conductor {
  final String id;
  final String codigo;
  final String nombres;
  final String apellidos;
  final String dni;
  final String licenciaNumero;
  final String licenciaCategoria; // A-IIIA, A-IIIB, A-IIIC
  final String licenciaVencimiento; // YYYY-MM-DD
  final String telefono;
  final String estado; // DESCANSADO, ACTIVO, LICENCIA, BAJA
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String sha256;
  final String syncStatus;

  const Conductor({
    required this.id,
    required this.codigo,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.licenciaNumero,
    required this.licenciaCategoria,
    required this.licenciaVencimiento,
    required this.telefono,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.sha256,
    required this.syncStatus,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();
  String get licenciaVigencia => licenciaVencimiento;
  int get horasDescansoAcumuladas => 12;

  int get diasParaVencerLicencia {
    try {
      final fecha = DateTime.parse(licenciaVencimiento);
      return fecha.difference(DateTime.now()).inDays;
    } catch (_) {
      return 999;
    }
  }

  bool get licenciaVencida => diasParaVencerLicencia < 0;
  bool get licenciaPorVencer => diasParaVencerLicencia >= 0 && diasParaVencerLicencia <= 30;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombres': nombres,
      'apellidos': apellidos,
      'dni': dni,
      'licencia_numero': licenciaNumero,
      'licencia_categoria': licenciaCategoria,
      'licencia_vencimiento': licenciaVencimiento,
      'telefono': telefono,
      'estado': estado,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'sha256': sha256,
      'sync_status': syncStatus,
    };
  }

  factory Conductor.fromMap(Map<String, dynamic> map) {
    return Conductor(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      nombres: (map['nombres'] as String?) ?? '',
      apellidos: (map['apellidos'] as String?) ?? '',
      dni: (map['dni'] as String?) ?? '',
      licenciaNumero: (map['licencia_numero'] as String?) ?? '',
      licenciaCategoria: (map['licencia_categoria'] as String?) ?? 'A-IIIC',
      licenciaVencimiento: (map['licencia_vencimiento'] as String?) ?? '',
      telefono: (map['telefono'] as String?) ?? '',
      estado: (map['estado'] as String?) ?? 'DESCANSADO',
      createdAt: map['created_at'] as String,
      updatedAt: (map['updated_at'] as String?) ?? map['created_at'] as String,
      deletedAt: map['deleted_at'] as String?,
      sha256: (map['sha256'] as String?) ?? '',
      syncStatus: (map['sync_status'] as String?) ?? 'OK',
    );
  }

  Conductor copyWith({
    String? id,
    String? codigo,
    String? nombres,
    String? apellidos,
    String? dni,
    String? licenciaNumero,
    String? licenciaCategoria,
    String? licenciaVencimiento,
    String? telefono,
    String? estado,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? sha256,
    String? syncStatus,
  }) {
    return Conductor(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      dni: dni ?? this.dni,
      licenciaNumero: licenciaNumero ?? this.licenciaNumero,
      licenciaCategoria: licenciaCategoria ?? this.licenciaCategoria,
      licenciaVencimiento: licenciaVencimiento ?? this.licenciaVencimiento,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      sha256: sha256 ?? this.sha256,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
