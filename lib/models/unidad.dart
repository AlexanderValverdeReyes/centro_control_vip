class Unidad {
  final String id;
  final String codigo;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String chasis;
  final String motor;
  final int odometroKm;
  final int capacidadPasajeros;
  final int tanqueLitros;
  final int presionNominalPsi;
  final String tipoServicio;
  final String estado; // enAnden, enRuta, novedad, mantenimiento, baja
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String sha256;
  final String syncStatus; // OK, PENDING, FAIL

  // Telemetría en tiempo de ejecución
  final double combustiblePct;
  final double velocidadKmh;
  final double lat;
  final double lng;

  const Unidad({
    required this.id,
    required this.codigo,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.chasis,
    required this.motor,
    required this.odometroKm,
    required this.capacidadPasajeros,
    required this.tanqueLitros,
    required this.presionNominalPsi,
    required this.tipoServicio,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.sha256,
    required this.syncStatus,
    this.combustiblePct = 0.85,
    this.velocidadKmh = 0.0,
    this.lat = -12.0620,
    this.lng = -77.0180,
  });

  int get anioFabricacion => anio;
  double get presionNeumaticosPsi => presionNominalPsi.toDouble();
  bool get presionNeumaticosValida => presionNominalPsi >= 100 && presionNominalPsi <= 130;
  double get kilometrajeActual => odometroKm.toDouble();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'chasis': chasis,
      'motor': motor,
      'odometro_km': odometroKm,
      'capacidad_pasajeros': capacidadPasajeros,
      'tanque_litros': tanqueLitros,
      'presion_nominal_psi': presionNominalPsi,
      'tipo_servicio': tipoServicio,
      'estado': estado,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'sha256': sha256,
      'sync_status': syncStatus,
    };
  }

  factory Unidad.fromMap(Map<String, dynamic> map) {
    return Unidad(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      placa: (map['placa'] as String?) ?? '',
      marca: (map['marca'] as String?) ?? '',
      modelo: (map['modelo'] as String?) ?? '',
      anio: (map['anio'] as int?) ?? DateTime.now().year,
      chasis: (map['chasis'] as String?) ?? '',
      motor: (map['motor'] as String?) ?? '',
      odometroKm: (map['odometro_km'] as int?) ?? 0,
      capacidadPasajeros: (map['capacidad_pasajeros'] as int?) ?? 45,
      tanqueLitros: (map['tanque_litros'] as int?) ?? 350,
      presionNominalPsi: (map['presion_nominal_psi'] as int?) ?? 115,
      tipoServicio: (map['tipo_servicio'] as String?) ?? 'VIP EXPRESS',
      estado: (map['estado'] as String?) ?? 'enAnden',
      createdAt: map['created_at'] as String,
      updatedAt: (map['updated_at'] as String?) ?? map['created_at'] as String,
      deletedAt: map['deleted_at'] as String?,
      sha256: (map['sha256'] as String?) ?? '',
      syncStatus: (map['sync_status'] as String?) ?? 'OK',
      combustiblePct: (map['combustible_pct'] as num?)?.toDouble() ?? 0.85,
      velocidadKmh: (map['velocidad_kmh'] as num?)?.toDouble() ?? 0.0,
      lat: (map['lat'] as num?)?.toDouble() ?? -12.0620,
      lng: (map['lng'] as num?)?.toDouble() ?? -77.0180,
    );
  }

  Unidad copyWith({
    String? id,
    String? codigo,
    String? placa,
    String? marca,
    String? modelo,
    int? anio,
    String? chasis,
    String? motor,
    int? odometroKm,
    int? capacidadPasajeros,
    int? tanqueLitros,
    int? presionNominalPsi,
    String? tipoServicio,
    String? estado,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? sha256,
    String? syncStatus,
    double? combustiblePct,
    double? velocidadKmh,
    double? lat,
    double? lng,
  }) {
    return Unidad(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      placa: placa ?? this.placa,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      chasis: chasis ?? this.chasis,
      motor: motor ?? this.motor,
      odometroKm: odometroKm ?? this.odometroKm,
      capacidadPasajeros: capacidadPasajeros ?? this.capacidadPasajeros,
      tanqueLitros: tanqueLitros ?? this.tanqueLitros,
      presionNominalPsi: presionNominalPsi ?? this.presionNominalPsi,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      sha256: sha256 ?? this.sha256,
      syncStatus: syncStatus ?? this.syncStatus,
      combustiblePct: combustiblePct ?? this.combustiblePct,
      velocidadKmh: velocidadKmh ?? this.velocidadKmh,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
