import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/ruta.dart';

class RutaDao {
  final Database db;

  RutaDao(this.db);

  Future<List<Ruta>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'rutas',
      where: 'activa = 1',
      orderBy: 'codigo ASC',
    );
    return maps.map((m) => Ruta.fromMap(m)).toList();
  }

  Future<Ruta?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'rutas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Ruta.fromMap(maps.first);
  }
}
