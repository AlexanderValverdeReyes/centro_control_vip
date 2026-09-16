import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/database_helper.dart';
import '../data/dao/cola_sync_dao.dart';
import '../data/remote/api_client.dart';
import 'constants.dart';

class SyncEngine {
  static final SyncEngine instance = SyncEngine._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiClient _apiClient = ApiClient();
  final Connectivity _connectivity = Connectivity();

  Timer? _timer;
  bool _isSyncing = false;
  int _pendingCount = 0;
  SyncStatus _currentStatus = SyncStatus.ok;

  final _statusController = StreamController<SyncEngineStatus>.broadcast();
  Stream<SyncEngineStatus> get statusStream => _statusController.stream;

  SyncEngine._internal();

  SyncStatus get currentStatus => _currentStatus;
  int get pendingCount => _pendingCount;

  void start() {
    _timer?.cancel();
    // Ejecutar ciclo inicial después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () => syncNow());
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => syncNow(),
    );
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final db = await _dbHelper.database;
      final colaDao = ColaSyncDao(db);

      _pendingCount = await colaDao.countPendientes();
      if (_pendingCount == 0) {
        _updateStatus(SyncStatus.ok, 0);
        _isSyncing = false;
        return;
      }

      // Verificar conectividad física
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasConnection = connectivityResult.any((r) => r != ConnectivityResult.none);

      if (!hasConnection) {
        _updateStatus(SyncStatus.pending, _pendingCount);
        _isSyncing = false;
        return;
      }

      // Obtener lote de hasta 20 filas ordenadas por created_at
      final pendientes = await colaDao.getPendientes(limit: AppConstants.syncBatchSize);
      if (pendientes.isEmpty) {
        _updateStatus(SyncStatus.ok, 0);
        _isSyncing = false;
        return;
      }

      _updateStatus(SyncStatus.pending, _pendingCount);

      for (final item in pendientes) {
        try {
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;

          if (item.entidad == 'despachos') {
            await _apiClient.pushDespachos([payload]);
            await db.update('despachos', {'sync': 'OK'}, where: 'id = ?', whereArgs: [item.entidadId]);
          } else if (item.entidad == 'reportes_checkpoint') {
            await _apiClient.pushCheckpoints([payload]);
            await db.update('reportes_checkpoint', {'sync_status': 'OK'}, where: 'id = ?', whereArgs: [item.entidadId]);
          } else if (item.entidad == 'unidades' || item.entidad == 'conductores') {
            await _apiClient.pushFlota([payload]);
            await db.update(item.entidad, {'sync_status': 'OK'}, where: 'id = ?', whereArgs: [item.entidadId]);
          }

          // Eliminar de cola tras commit remoto
          await colaDao.delete(item.id);
        } catch (e) {
          final nuevoIntento = item.intentos + 1;
          final delayIndex = (nuevoIntento - 1).clamp(0, AppConstants.backoffDelaysSeconds.length - 1);
          final delaySeconds = AppConstants.backoffDelaysSeconds[delayIndex];
          final proximo = DateTime.now().add(Duration(seconds: delaySeconds)).toIso8601String();

          if (nuevoIntento >= 5) {
            // Rechazo persistente: marcar FAIL
            if (item.entidad == 'despachos') {
              await db.update('despachos', {'sync': 'FAIL'}, where: 'id = ?', whereArgs: [item.entidadId]);
            } else if (item.entidad == 'unidades' || item.entidad == 'conductores') {
              await db.update(item.entidad, {'sync_status': 'FAIL'}, where: 'id = ?', whereArgs: [item.entidadId]);
            }
          }

          await colaDao.updateFallo(item.id, nuevoIntento, proximo, e.toString());
        }
      }

      _pendingCount = await colaDao.countPendientes();
      final List<Map<String, dynamic>> fallidos = await db.rawQuery(
        "SELECT COUNT(*) as count FROM despachos WHERE sync = 'FAIL'",
      );
      final numFallidos = (fallidos.first['count'] as int?) ?? 0;

      if (numFallidos > 0) {
        _updateStatus(SyncStatus.fail, _pendingCount);
      } else if (_pendingCount > 0) {
        _updateStatus(SyncStatus.pending, _pendingCount);
      } else {
        _updateStatus(SyncStatus.ok, 0);
      }
    } catch (_) {
      _updateStatus(SyncStatus.pending, _pendingCount);
    } finally {
      _isSyncing = false;
    }
  }

  void _updateStatus(SyncStatus status, int count) {
    _currentStatus = status;
    _pendingCount = count;
    _statusController.add(SyncEngineStatus(status: status, pendingCount: count));
  }
}

class SyncEngineStatus {
  final SyncStatus status;
  final int pendingCount;

  const SyncEngineStatus({required this.status, required this.pendingCount});
}
