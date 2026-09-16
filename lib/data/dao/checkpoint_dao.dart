import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/checkpoint.dart';

class CheckpointDao {
  final Database db;

  CheckpointDao(this.db);

  Future<List<Checkpoint>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      orderBy: 'orden ASC',
    );
    return maps.map((m) => Checkpoint.fromMap(m)).toList();
  }

  Future<List<Checkpoint>> getByRuta(String rutaId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      where: 'ruta_id = ?',
      whereArgs: [rutaId],
      orderBy: 'orden ASC',
    );
    return maps.map((m) => Checkpoint.fromMap(m)).toList();
  }

  Future<Checkpoint?> getByCodigo(String codigo) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Checkpoint.fromMap(maps.first);
  }
}
