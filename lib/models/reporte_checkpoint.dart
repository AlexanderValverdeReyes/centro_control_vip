class ReporteCheckpoint {
  final String id;
  final String despachoId;
  final String checkpointId;
  final String timestampLocal;
  final double latReportada;
  final double lngReportada;
  final String origen; // MANUAL, GPS_AUTO, CONDUCTOR
  final String syncStatus;
  final String sha256;

  const ReporteCheckpoint({
    required this.id,
    required this.despachoId,
    required this.checkpointId,
    required this.timestampLocal,
    required this.latReportada,
    required this.lngReportada,
    required this.origen,
    required this.syncStatus,
    required this.sha256,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'despacho_id': despachoId,
      'checkpoint_id': checkpointId,
      'timestamp_local': timestampLocal,
      'lat_reportada': latReportada,
      'lng_reportada': lngReportada,
      'origen': origen,
      'sync_status': syncStatus,
      'sha256': sha256,
    };
  }

  factory ReporteCheckpoint.fromMap(Map<String, dynamic> map) {
    return ReporteCheckpoint(
      id: map['id'] as String,
      despachoId: map['despacho_id'] as String,
      checkpointId: map['checkpoint_id'] as String,
      timestampLocal: map['timestamp_local'] as String,
      latReportada: (map['lat_reportada'] as num).toDouble(),
      lngReportada: (map['lng_reportada'] as num).toDouble(),
      origen: (map['origen'] as String?) ?? 'MANUAL',
      syncStatus: (map['sync_status'] as String?) ?? 'PENDING',
      sha256: (map['sha256'] as String?) ?? '',
    );
  }
}
