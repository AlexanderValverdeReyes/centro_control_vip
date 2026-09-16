import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/despacho.dart';

class DespachoDao {
  final Database db;

  DespachoDao(this.db);

  static const String _joinQuery = '''
    SELECT 
      d.*,
      u.codigo AS unidad_codigo,
      u.placa AS unidad_placa,
      (c.nombres || ' ' || c.apellidos) AS conductor_nombre,
      r.nombre AS ruta_nombre,
      a.numero AS anden_numero
    FROM despachos d
    LEFT JOIN unidades u ON d.unidad_id = u.id
    LEFT JOIN conductores c ON d.conductor_id = c.id
    LEFT JOIN rutas r ON d.ruta_id = r.id
    LEFT JOIN andenes a ON d.anden_id = a.id
  ''';

  Future<List<Despacho>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '$_joinQuery ORDER BY d.created_at DESC',
    );
    return maps.map((m) => Despacho.fromMap(m)).toList();
  }

  Future<Despacho?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '$_joinQuery WHERE d.id = ? LIMIT 1',
      [id],
    );
    if (maps.isEmpty) return null;
    return Despacho.fromMap(maps.first);
  }

  Future<List<Despacho>> getActivosEnRuta() async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      $_joinQuery 
      WHERE u.estado = 'enRuta'
      ORDER BY d.created_at DESC
      ''',
    );
    return maps.map((m) => Despacho.fromMap(m)).toList();
  }

  Future<int> insert(Despacho despacho, [Transaction? txn]) async {
    final executor = txn ?? db;
    return await executor.insert(
      'despachos',
      despacho.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProgreso(
    String id,
    String ultimoCheckpointId,
    double progresoRuta, [
    Transaction? txn,
  ]) async {
    final executor = txn ?? db;
    return await executor.update(
      'despachos',
      {
        'ultimo_checkpoint_id': ultimoCheckpointId,
        'progreso_ruta': progresoRuta,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSyncStatus(String id, String syncStatus) async {
    return await db.update(
      'despachos',
      {'sync': syncStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
