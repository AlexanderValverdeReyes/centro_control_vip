import 'package:flutter/material.dart';
import '../data/repositories/rastreo_repository.dart';
import '../models/checkpoint.dart';
import '../models/restriccion.dart';

class RastreoProvider extends ChangeNotifier {
  final RastreoRepository _repository;

  List<Checkpoint> _checkpoints = [];
  List<Restriccion> _restricciones = [];
  String _selectedCorredor = 'MALA — LIMA';
  Checkpoint? _inspectedCheckpoint;
  String? _ultimoCheckpointReportadoCodigo;
  bool _isLoading = false;

  List<Checkpoint> get checkpoints => _checkpoints;
  List<Restriccion> get restricciones => _restricciones;
  String get selectedCorredor => _selectedCorredor;
  Checkpoint? get inspectedCheckpoint => _inspectedCheckpoint;
  String? get ultimoCheckpointReportadoCodigo => _ultimoCheckpointReportadoCodigo;
  bool get isLoading => _isLoading;

  RastreoProvider([RastreoRepository? repository])
      : _repository = repository ?? RastreoRepository() {
    cargarRastreo();
  }

  Future<void> cargarRastreo() async {
    _isLoading = true;
    notifyListeners();
    try {
      _checkpoints = await _repository.getCheckpoints();
      _restricciones = await _repository.getRestricciones();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void seleccionarCorredor(String corredor) {
    _selectedCorredor = corredor;
    _inspectedCheckpoint = null;
    notifyListeners();
  }

  void inspeccionarCheckpoint(Checkpoint? chk) {
    _inspectedCheckpoint = chk;
    notifyListeners();
  }

  Future<double> reportarPaso({
    required String despachoId,
    required String checkpointCodigo,
    String origen = 'MANUAL',
  }) async {
    final progreso = await _repository.reportarPasoCheckpoint(
      despachoId: despachoId,
      checkpointId: checkpointCodigo,
      origen: origen,
    );
    _ultimoCheckpointReportadoCodigo = checkpointCodigo;
    notifyListeners();
    return progreso;
  }
}
