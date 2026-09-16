import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/cola_sync_item.dart';

class ColaSyncDao {
  final Database db;

  ColaSyncDao(this.db);

  Future<int> insert(ColaSyncItem item, [Transaction? txn]) async {
    final executor = txn ?? db;
    return await executor.insert(
      'cola_sync',
      item.toMap(),
    );
  }

  Future<List<ColaSyncItem>> getPendientes({int limit = 20}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'cola_sync',
      orderBy: 'created_at ASC',
      limit: limit,
    );
    return maps.map((m) => ColaSyncItem.fromMap(m)).toList();
  }

  Future<int> delete(String id) async {
    return await db.delete(
      'cola_sync',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateFallo(String id, int intentos, String proximoIntento, String error) async {
    return await db.update(
      'cola_sync',
      {
        'intentos': intentos,
        'proximo_intento': proximoIntento,
        'ultimo_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countPendientes() async {
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM cola_sync');
    if (res.isEmpty) return 0;
    return (res.first['count'] as int?) ?? 0;
  }
}
