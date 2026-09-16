import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';
import '../dao/unidad_dao.dart';
import '../dao/conductor_dao.dart';
import '../dao/cola_sync_dao.dart';
import '../dao/bitacora_dao.dart';
import '../../models/unidad.dart';
import '../../models/conductor.dart';
import '../../models/cola_sync_item.dart';
import '../../models/bitacora_item.dart';

class FlotaRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  FlotaRepository([DatabaseHelper? dbHelper]) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Unidad>> getUnidades() async {
    final db = await _dbHelper.database;
    return await UnidadDao(db).getAll();
  }

  Future<List<Conductor>> getConductores() async {
    final db = await _dbHelper.database;
    return await ConductorDao(db).getAll();
  }

  Future<void> registrarUnidad(Unidad unidad) async {
    final db = await _dbHelper.database;
    final unidadDao = UnidadDao(db);

    // Validación de código único
    final existe = await unidadDao.getByCodigo(unidad.codigo);
    if (existe != null) {
      throw Exception('El código de unidad ${unidad.codigo} ya se encuentra registrado.');
    }

    final id = unidad.id.isNotEmpty ? unidad.id : _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final hash = sha256.convert(utf8.encode('${unidad.codigo}_$now')).toString();

    final nuevaUnidad = unidad.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      sha256: hash,
      syncStatus: 'PENDING',
    );

    await db.transaction((txn) async {
      await txn.insert('unidades', nuevaUnidad.toMap());

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: id,
          accion: 'INSERT',
          payload: jsonEncode(nuevaUnidad.toMap()),
          sha256: hash,
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: id,
          accion: 'INSERT',
          payloadJson: jsonEncode(nuevaUnidad.toMap()),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }

  Future<void> actualizarUnidad(Unidad unidad) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final hash = sha256.convert(utf8.encode('${unidad.codigo}_$now')).toString();
    final actualizada = unidad.copyWith(updatedAt: now, sha256: hash, syncStatus: 'PENDING');

    await db.transaction((txn) async {
      await txn.update(
        'unidades',
        actualizada.toMap(),
        where: 'id = ?',
        whereArgs: [unidad.id],
      );

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: unidad.id,
          accion: 'UPDATE',
          payload: jsonEncode(actualizada.toMap()),
          sha256: hash,
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: unidad.id,
          accion: 'UPDATE',
          payloadJson: jsonEncode(actualizada.toMap()),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }

  Future<void> darDeBajaUnidad(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.update(
        'unidades',
        {'deleted_at': now, 'estado': 'baja', 'updated_at': now, 'sync_status': 'PENDING'},
        where: 'id = ?',
        whereArgs: [id],
      );

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: id,
          accion: 'DELETE',
          payload: jsonEncode({'id': id, 'deleted_at': now}),
          sha256: sha256.convert(utf8.encode('${id}_DELETE_$now')).toString(),
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: id,
          accion: 'DELETE',
          payloadJson: jsonEncode({'id': id}),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }

  Future<void> registrarConductor(Conductor conductor) async {
    final db = await _dbHelper.database;
    final conductorDao = ConductorDao(db);

    final existe = await conductorDao.getByCodigo(conductor.codigo);
    if (existe != null) {
      throw Exception('El código de conductor ${conductor.codigo} ya se encuentra registrado.');
    }

    final id = conductor.id.isNotEmpty ? conductor.id : _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final hash = sha256.convert(utf8.encode('${conductor.codigo}_$now')).toString();

    final nuevo = conductor.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      sha256: hash,
      syncStatus: 'PENDING',
    );

    await db.transaction((txn) async {
      await txn.insert('conductores', nuevo.toMap());

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'conductores',
          entidadId: id,
          accion: 'INSERT',
          payload: jsonEncode(nuevo.toMap()),
          sha256: hash,
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'conductores',
          entidadId: id,
          accion: 'INSERT',
          payloadJson: jsonEncode(nuevo.toMap()),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }

  Future<void> actualizarConductor(Conductor conductor) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final hash = sha256.convert(utf8.encode('${conductor.codigo}_$now')).toString();
    final actualizado = conductor.copyWith(updatedAt: now, sha256: hash, syncStatus: 'PENDING');

    await db.transaction((txn) async {
      await txn.update(
        'conductores',
        actualizado.toMap(),
        where: 'id = ?',
        whereArgs: [conductor.id],
      );

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'conductores',
          entidadId: conductor.id,
          accion: 'UPDATE',
          payload: jsonEncode(actualizado.toMap()),
          sha256: hash,
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'conductores',
          entidadId: conductor.id,
          accion: 'UPDATE',
          payloadJson: jsonEncode(actualizado.toMap()),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }

  Future<void> darDeBajaConductor(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.update(
        'conductores',
        {'deleted_at': now, 'estado': 'BAJA', 'updated_at': now, 'sync_status': 'PENDING'},
        where: 'id = ?',
        whereArgs: [id],
      );

      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'conductores',
          entidadId: id,
          accion: 'DELETE',
          payload: jsonEncode({'id': id, 'deleted_at': now}),
          sha256: sha256.convert(utf8.encode('${id}_DELETE_$now')).toString(),
          createdAt: now,
        ),
        txn,
      );

      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'conductores',
          entidadId: id,
          accion: 'DELETE',
          payloadJson: jsonEncode({'id': id}),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }
}
