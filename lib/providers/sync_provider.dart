import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/sync_engine.dart';

class SyncProvider extends ChangeNotifier {
  final SyncEngine _engine = SyncEngine.instance;
  SyncStatus _status = SyncStatus.ok;
  int _pendingCount = 0;
  StreamSubscription? _sub;

  SyncStatus get status => _status;
  int get pendingCount => _pendingCount;

  SyncProvider() {
    _status = _engine.currentStatus;
    _pendingCount = _engine.pendingCount;
    _sub = _engine.statusStream.listen((data) {
      _status = data.status;
      _pendingCount = data.pendingCount;
      notifyListeners();
    });
  }

  Future<void> forzarSincronizacion() async {
    await _engine.syncNow();
    _status = _engine.currentStatus;
    _pendingCount = _engine.pendingCount;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
