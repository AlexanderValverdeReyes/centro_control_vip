import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/unidad.dart';

class UnidadDao {
  final Database db;

  UnidadDao(this.db);

  Future<List<Unidad>> getAll({bool includeDeleted = false}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'unidades',
      where: includeDeleted ? null : 'deleted_at IS NULL',
      orderBy: 'codigo ASC',
    );
    return maps.map((m) => Unidad.fromMap(m)).toList();
  }

  Future<Unidad?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'unidades',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Unidad.fromMap(maps.first);
  }

  Future<Unidad?> getByCodigo(String codigo) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'unidades',
      where: 'codigo = ? AND deleted_at IS NULL',
      whereArgs: [codigo],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Unidad.fromMap(maps.first);
  }

  Future<int> insert(Unidad unidad) async {
    return await db.insert(
      'unidades',
      unidad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<int> update(Unidad unidad) async {
    return await db.update(
      'unidades',
      unidad.toMap(),
      where: 'id = ?',
      whereArgs: [unidad.id],
    );
  }

  Future<int> updateEstado(String id, String nuevoEstado) async {
    return await db.update(
      'unidades',
      {
        'estado': nuevoEstado,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> softDelete(String id) async {
    return await db.update(
      'unidades',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'estado': 'baja',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
