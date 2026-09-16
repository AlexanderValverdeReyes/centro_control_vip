import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PreferenciasDao {
  final Database db;

  PreferenciasDao(this.db);

  Future<String?> get(String clave) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'preferencias',
      where: 'clave = ?',
      whereArgs: [clave],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['valor'] as String?;
  }

  Future<void> set(String clave, String valor) async {
    await db.insert(
      'preferencias',
      {'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
