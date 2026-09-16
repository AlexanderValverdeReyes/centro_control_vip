class AppConstants {
  static const String terminalActivoId = 'TER-LIMA-JVICTORIA';
  static const String terminalActivoNombre = 'Terminal Terrestre Javier Prado';
  static const String terminalMalaId = 'TER-MALA';
  static const String terminalMalaNombre = 'Terminal Terrestre de Mala';
  static const String rutaMalaLimaId = 'R-MALA-LIMA';
  static const String rutaLimaMalaId = 'R-LIMA-MALA';

  // Expresiones regulares de validación de códigos
  static final RegExp unidadCodigoRegex = RegExp(r'^BUS-VIP-\d{3}$');
  static final RegExp conductorCodigoRegex = RegExp(r'^OP-\d{3}$');
  static final RegExp dniRegex = RegExp(r'^\d{8}$');
  static final RegExp placaRegex = RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$');

  // Parámetros de telemetría y seguridad
  static const int presionMinimaPsi = 100;
  static const int presionMaximaPsi = 130;
  static const double combustibleAlertaMin = 0.20; // 20%
  static const double metaOtpPorcentaje = 95.0;

  // Sync Engine
  static const int syncIntervalSeconds = 30;
  static const int syncBatchSize = 20;
  static const List<int> backoffDelaysSeconds = [5, 15, 45, 120, 300];
}

enum EstadoUnidad {
  enAnden,
  enRuta,
  novedad,
  mantenimiento,
  baja,
}

extension EstadoUnidadExtension on EstadoUnidad {
  String get nameString {
    switch (this) {
      case EstadoUnidad.enAnden:
        return 'enAnden';
      case EstadoUnidad.enRuta:
        return 'enRuta';
      case EstadoUnidad.novedad:
        return 'novedad';
      case EstadoUnidad.mantenimiento:
        return 'mantenimiento';
      case EstadoUnidad.baja:
        return 'baja';
    }
  }

  String get label {
    switch (this) {
      case EstadoUnidad.enAnden:
        return 'EN ANDÉN';
      case EstadoUnidad.enRuta:
        return 'EN RUTA';
      case EstadoUnidad.novedad:
        return 'NOVEDAD';
      case EstadoUnidad.mantenimiento:
        return 'MANTENIMIENTO';
      case EstadoUnidad.baja:
        return 'DE BAJA';
    }
  }
}

enum EstadoConductor {
  descansado,
  activo,
  licencia,
  baja,
}

extension EstadoConductorExtension on EstadoConductor {
  String get nameString {
    switch (this) {
      case EstadoConductor.descansado:
        return 'DESCANSADO';
      case EstadoConductor.activo:
        return 'ACTIVO';
      case EstadoConductor.licencia:
        return 'LICENCIA';
      case EstadoConductor.baja:
        return 'BAJA';
    }
  }
}

enum SyncStatus {
  ok,
  pending,
  fail,
}

extension SyncStatusExtension on SyncStatus {
  String get nameString {
    switch (this) {
      case SyncStatus.ok:
        return 'OK';
      case SyncStatus.pending:
        return 'PENDING';
      case SyncStatus.fail:
        return 'FAIL';
    }
  }
}
