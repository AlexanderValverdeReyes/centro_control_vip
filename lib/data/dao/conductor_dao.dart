import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/conductor.dart';

class ConductorDao {
  final Database db;

  ConductorDao(this.db);

  Future<List<Conductor>> getAll({bool includeDeleted = false}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'conductores',
      where: includeDeleted ? null : 'deleted_at IS NULL',
      orderBy: 'codigo ASC',
    );
    return maps.map((m) => Conductor.fromMap(m)).toList();
  }

  Future<Conductor?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'conductores',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Conductor.fromMap(maps.first);
  }

  Future<Conductor?> getByCodigo(String codigo) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'conductores',
      where: 'codigo = ? AND deleted_at IS NULL',
      whereArgs: [codigo],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Conductor.fromMap(maps.first);
  }

  Future<int> insert(Conductor conductor) async {
    return await db.insert(
      'conductores',
      conductor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<int> update(Conductor conductor) async {
    return await db.update(
      'conductores',
      conductor.toMap(),
      where: 'id = ?',
      whereArgs: [conductor.id],
    );
  }

  Future<int> updateEstado(String id, String nuevoEstado) async {
    return await db.update(
      'conductores',
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
      'conductores',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'estado': 'BAJA',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
