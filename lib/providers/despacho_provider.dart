import 'package:flutter/material.dart';
import '../data/repositories/despacho_repository.dart';
import '../models/despacho.dart';
import '../models/anden.dart';

class DespachoProvider extends ChangeNotifier {
  final DespachoRepository _repository;

  List<Despacho> _despachos = [];
  List<Anden> _andenes = [];
  bool _isLoading = false;
  String _filtroRuta = 'Todas las Rutas';
  String _filtroSync = 'Todos';

  List<Despacho> get despachos => _despachos;
  List<Anden> get andenes => _andenes;
  bool get isLoading => _isLoading;
  String get filtroRuta => _filtroRuta;
  String get filtroSync => _filtroSync;

  DespachoProvider([DespachoRepository? repository])
      : _repository = repository ?? DespachoRepository() {
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _despachos = await _repository.getDespachos();
      _andenes = await _repository.getAndenes();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setFiltroRuta(String ruta) {
    _filtroRuta = ruta;
    notifyListeners();
  }

  void setFiltroSync(String sync) {
    _filtroSync = sync;
    notifyListeners();
  }

  List<Despacho> get despachosFiltrados {
    return _despachos.where((d) {
      final matchRuta = _filtroRuta == 'Todas las Rutas' ||
          (d.rutaNombre != null && d.rutaNombre!.contains(_filtroRuta));
      final matchSync = _filtroSync == 'Todos' || d.sync == _filtroSync;
      return matchRuta && matchSync;
    }).toList();
  }

  List<Anden> get andenesDisponibles {
    return _andenes.where((a) => a.isDisponible).toList();
  }

  Future<Despacho> registrarDespacho({
    required String unidadId,
    required String conductorId,
    required String rutaId,
    required String andenId,
    required String salidaProg,
    required String tipoServicio,
  }) async {
    final dsp = await _repository.crearDespacho(
      unidadId: unidadId,
      conductorId: conductorId,
      rutaId: rutaId,
      andenId: andenId,
      salidaProg: salidaProg,
      tipoServicio: tipoServicio,
    );
    await cargarDatos();
    return dsp;
  }

  Future<void> despacharInmediatamente(String despachoId) async {
    await _repository.despacharInmediatamente(despachoId);
    await cargarDatos();
  }

  Future<void> reintentarSync(String despachoId) async {
    await _repository.reintentarSync(despachoId);
    await cargarDatos();
  }
}
