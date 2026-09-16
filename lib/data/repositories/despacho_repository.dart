import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';
import '../dao/despacho_dao.dart';
import '../dao/anden_dao.dart';
import '../dao/unidad_dao.dart';
import '../dao/conductor_dao.dart';
import '../dao/cola_sync_dao.dart';
import '../dao/bitacora_dao.dart';
import '../../models/despacho.dart';
import '../../models/anden.dart';
import '../../models/cola_sync_item.dart';
import '../../models/bitacora_item.dart';

class DespachoRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  DespachoRepository([DatabaseHelper? dbHelper]) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Despacho>> getDespachos() async {
    final db = await _dbHelper.database;
    return await DespachoDao(db).getAll();
  }

  Future<List<Anden>> getAndenes() async {
    final db = await _dbHelper.database;
    return await AndenDao(db).getAll();
  }

  Future<Despacho> crearDespacho({
    required String unidadId,
    required String conductorId,
    required String rutaId,
    required String andenId,
    required String salidaProg,
    required String tipoServicio,
  }) async {
    final db = await _dbHelper.database;
    final unidadDao = UnidadDao(db);
    final conductorDao = ConductorDao(db);
    final andenDao = AndenDao(db);

    // 1. Validaciones de Dominio estrictas
    final unidad = await unidadDao.getById(unidadId);
    if (unidad == null) throw Exception('Unidad no encontrada.');
    if (unidad.estado == 'novedad' || unidad.estado == 'mantenimiento' || unidad.estado == 'baja') {
      throw Exception('La unidad ${unidad.codigo} no está operativa (Estado: ${unidad.estado}).');
    }

    final conductor = await conductorDao.getById(conductorId);
    if (conductor == null) throw Exception('Conductor no encontrado.');
    if (conductor.estado != 'DESCANSADO') {
      throw Exception('El conductor ${conductor.nombreCompleto} no está disponible (Estado: ${conductor.estado}).');
    }
    if (conductor.licenciaVencida) {
      throw Exception('La licencia del conductor ${conductor.nombreCompleto} está vencida.');
    }

    final anden = await andenDao.getById(andenId);
    if (anden == null) throw Exception('Andén no encontrado.');
    if (anden.estado != 'DISPONIBLE') {
      throw Exception('El andén ${anden.numero} no se encuentra disponible (Estado: ${anden.estado}).');
    }

    // 2. Generación de código único y hash SHA-256
    final now = DateTime.now();
    final random = Random();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final suffix = (random.nextInt(9000) + 1000).toString();
    final codigo = 'DSP-$year$month-$suffix';
    final despachoId = _uuid.v4();
    final uuidAudit = _uuid.v4();
    final nowIso = now.toIso8601String();
    final actualTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final shaContent = '$codigo|$unidadId|$conductorId|$rutaId|$andenId|$nowIso';
    final sha256Hex = sha256.convert(utf8.encode(shaContent)).toString();

    final nuevoDespacho = Despacho(
      id: despachoId,
      codigo: codigo,
      unidadId: unidadId,
      conductorId: conductorId,
      rutaId: rutaId,
      andenId: andenId,
      salidaProg: salidaProg,
      salidaReal: actualTime,
      desviacionMin: 0,
      tipoServicio: tipoServicio,
      sync: 'PENDING',
      uuid: uuidAudit,
      ultimoCheckpointId: 'TER-LIMA',
      progresoRuta: 0.0,
      createdAt: nowIso,
      sha256: sha256Hex,
      unidadCodigo: unidad.codigo,
      unidadPlaca: unidad.placa,
      conductorNombre: conductor.nombreCompleto,
      andenNumero: anden.numero,
    );

    // 3. Transacción Atómica Completa (BEGIN ... COMMIT)
    await db.transaction((txn) async {
      // a) Insertar Despacho
      await DespachoDao(db).insert(nuevoDespacho, txn);

      // b) Marcar Andén como Ocupado
      await AndenDao(db).updateEstado(andenId, 'OCUPADO', despachoId, txn);

      // c) Actualizar Unidad a enAnden
      await txn.update(
        'unidades',
        {'estado': 'enAnden', 'updated_at': nowIso},
        where: 'id = ?',
        whereArgs: [unidadId],
      );

      // d) Actualizar Conductor a ACTIVO
      await txn.update(
        'conductores',
        {'estado': 'ACTIVO', 'updated_at': nowIso},
        where: 'id = ?',
        whereArgs: [conductorId],
      );

      // e) Registrar en Bitácora de Transacciones
      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'despachos',
          entidadId: despachoId,
          accion: 'COMMIT_DESPACHO',
          payload: jsonEncode(nuevoDespacho.toMap()),
          sha256: sha256Hex,
          createdAt: nowIso,
        ),
        txn,
      );

      // f) Encolar en Cola Sync
      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'despachos',
          entidadId: despachoId,
          accion: 'INSERT',
          payloadJson: jsonEncode(nuevoDespacho.toMap()),
          proximoIntento: nowIso,
          createdAt: nowIso,
        ),
        txn,
      );
    });

    return nuevoDespacho;
  }

  Future<void> despacharInmediatamente(String despachoId) async {
    final db = await _dbHelper.database;
    final despacho = await DespachoDao(db).getById(despachoId);
    if (despacho == null) return;

    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // Poner unidad en ruta
      await txn.update(
        'unidades',
        {'estado': 'enRuta', 'updated_at': now},
        where: 'id = ?',
        whereArgs: [despacho.unidadId],
      );

      // Liberar andén
      await AndenDao(db).updateEstado(despacho.andenId, 'DISPONIBLE', null, txn);

      // Bitácora
      await BitacoraDao(db).insert(
        BitacoraItem(
          id: _uuid.v4(),
          entidad: 'despachos',
          entidadId: despachoId,
          accion: 'SALIDA_EN_RUTA',
          payload: jsonEncode({'despacho_id': despachoId, 'hora': now}),
          sha256: sha256.convert(utf8.encode('${despachoId}_SALIDA_$now')).toString(),
          createdAt: now,
        ),
        txn,
      );

      // Cola sync
      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'unidades',
          entidadId: despacho.unidadId,
          accion: 'UPDATE_ESTADO',
          payloadJson: jsonEncode({'id': despacho.unidadId, 'estado': 'enRuta'}),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }

  Future<void> reintentarSync(String despachoId) async {
    final db = await _dbHelper.database;
    final despacho = await DespachoDao(db).getById(despachoId);
    if (despacho == null) return;

    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await DespachoDao(db).updateSyncStatus(despachoId, 'PENDING');
      await ColaSyncDao(db).insert(
        ColaSyncItem(
          id: _uuid.v4(),
          entidad: 'despachos',
          entidadId: despachoId,
          accion: 'RETRY_SYNC',
          payloadJson: jsonEncode(despacho.toMap()),
          proximoIntento: now,
          createdAt: now,
        ),
        txn,
      );
    });
  }
}
