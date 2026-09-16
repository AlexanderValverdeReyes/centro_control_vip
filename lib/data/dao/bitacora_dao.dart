import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/bitacora_item.dart';

class BitacoraDao {
  final Database db;

  BitacoraDao(this.db);

  Future<int> insert(BitacoraItem item, [Transaction? txn]) async {
    final executor = txn ?? db;
    return await executor.insert(
      'bitacora_transacciones',
      item.toMap(),
    );
  }

  Future<List<BitacoraItem>> getRecientes({int limit = 50}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'bitacora_transacciones',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((m) => BitacoraItem.fromMap(m)).toList();
  }
}
