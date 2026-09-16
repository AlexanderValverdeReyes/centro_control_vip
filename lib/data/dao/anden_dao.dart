import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/anden.dart';

class AndenDao {
  final Database db;

  AndenDao(this.db);

  Future<List<Anden>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'andenes',
      orderBy: 'numero ASC',
    );
    return maps.map((m) => Anden.fromMap(m)).toList();
  }

  Future<Anden?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'andenes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Anden.fromMap(maps.first);
  }

  Future<int> updateEstado(
    String id,
    String estado,
    String? despachoId, [
    Transaction? txn,
  ]) async {
    final executor = txn ?? db;
    return await executor.update(
      'andenes',
      {
        'estado': estado,
        'despacho_actual_id': despachoId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
