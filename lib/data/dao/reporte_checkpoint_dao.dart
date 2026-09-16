import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/reporte_checkpoint.dart';

class ReporteCheckpointDao {
  final Database db;

  ReporteCheckpointDao(this.db);

  Future<int> insert(ReporteCheckpoint reporte, [Transaction? txn]) async {
    final executor = txn ?? db;
    return await executor.insert(
      'reportes_checkpoint',
      reporte.toMap(),
    );
  }

  Future<List<ReporteCheckpoint>> getByDespacho(String despachoId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'reportes_checkpoint',
      where: 'despacho_id = ?',
      whereArgs: [despachoId],
      orderBy: 'timestamp_local DESC',
    );
    return maps.map((m) => ReporteCheckpoint.fromMap(m)).toList();
  }

  Future<ReporteCheckpoint?> getUltimoReporte(String despachoId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'reportes_checkpoint',
      where: 'despacho_id = ?',
      whereArgs: [despachoId],
      orderBy: 'timestamp_local DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ReporteCheckpoint.fromMap(maps.first);
  }
}
