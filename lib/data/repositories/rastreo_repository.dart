import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';
import '../dao/checkpoint_dao.dart';
import '../dao/reporte_checkpoint_dao.dart';
import '../dao/despacho_dao.dart';
import '../dao/restriccion_dao.dart';
import '../dao/cola_sync_dao.dart';
import '../dao/bitacora_dao.dart';
import '../../models/checkpoint.dart';
import '../../models/reporte_checkpoint.dart';
import '../../models/restriccion.dart';
import '../../models/cola_sync_item.dart';
import '../../models/bitacora_item.dart';

class RastreoRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  RastreoRepository([DatabaseHelper? dbHelper]) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Checkpoint>> getCheckpoints() async {
    final db = await _dbHelper.database;
    return await CheckpointDao(db).getAll();
  }

  Future<List<Restriccion>> getRestricciones() async {
    final db = await _dbHelper.database;
    return await RestriccionDao(db).getActivas();
  }

  Future<double> reportarPasoCheckpoint({
    required String despachoId,
    required String checkpointId,
    String origen = 'MANUAL',
  }) async {
    final db = await _dbHelper.database;
    final checkpointDao = CheckpointDao(db);
    final despachoDao = DespachoDao(db);

    // Obtener checkpoint
    final checkpoints = await checkpointDao.getAll();
    final chk = checkpoints.firstWhere(
      (c) => c.id == checkpointId || c.codigo == checkpointId,
      orElse: () => checkpoints.first,
    );

    // Calcular progreso de ruta (0.0 en Mala km 90, 1.0 en Lima km 0)
    // Para sentido Sur a Norte:
    final progreso = ((90.0 - chk.km) / 90.0).clamp(0.0, 1.0);

    final now = DateTime.now().toIso8601String();
    final reporteId = _uuid.v4();
    final sha256Hex = sha256.convert(utf8.encode('$despachoId|${chk.codigo}|$now')).toString();

    final reporte = ReporteCheckpoint(
      id: reporteId,
      despachoId: despachoId,
      checkpointId: chk.codigo,
      timestampLocal: now,
      latReportada: chk.lat,
      lngReportada: chk.lng,
      origen: origen,
      syncStatus: 'PENDING',
      sha256: sha256Hex,
    );

    await db.transaction((txn) async {
      await ReporteCheckpointDao(db).insert(reporte, txn);
      await despachoDao.updateProgreso(despachoId, chk.codigo, progreso, txn);

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'reportes_checkpoint',
          entidadId: reporteId,
          accion: 'PASO_CHECKPOINT',
          payload: jsonEncode(reporte.toMap()),
          sha256: sha256Hex,
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'reportes_checkpoint',
          entidadId: reporteId,
          accion: 'INSERT',
          payloadJson: jsonEncode(reporte.toMap()),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });

    return progreso;
  }
}
