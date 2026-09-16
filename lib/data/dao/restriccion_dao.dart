import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/restriccion.dart';

class RestriccionDao {
  final Database db;

  RestriccionDao(this.db);

  Future<List<Restriccion>> getActivas() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'restricciones',
      where: 'activa = 1',
      orderBy: 'km ASC',
    );
    return maps.map((m) => Restriccion.fromMap(m)).toList();
  }
}
