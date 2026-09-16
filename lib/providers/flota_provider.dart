import 'package:flutter/material.dart';
import '../data/repositories/flota_repository.dart';
import '../models/unidad.dart';
import '../models/conductor.dart';

class FlotaProvider extends ChangeNotifier {
  final FlotaRepository _repository;

  List<Unidad> _unidades = [];
  List<Conductor> _conductores = [];
  bool _isLoading = false;
  String _filtroTexto = '';

  List<Unidad> get unidades => _unidades;
  List<Conductor> get conductores => _conductores;
  bool get isLoading => _isLoading;
  String get filtroTexto => _filtroTexto;

  FlotaProvider([FlotaRepository? repository]) : _repository = repository ?? FlotaRepository() {
    cargarFlota();
  }

  Future<void> cargarFlota() async {
    _isLoading = true;
    notifyListeners();
    try {
      _unidades = await _repository.getUnidades();
      _conductores = await _repository.getConductores();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setFiltroTexto(String texto) {
    _filtroTexto = texto.trim().toLowerCase();
    notifyListeners();
  }

  List<Unidad> get unidadesFiltradas {
    if (_filtroTexto.isEmpty) return _unidades;
    return _unidades.where((u) {
      return u.codigo.toLowerCase().contains(_filtroTexto) ||
          u.placa.toLowerCase().contains(_filtroTexto) ||
          u.marca.toLowerCase().contains(_filtroTexto) ||
          u.modelo.toLowerCase().contains(_filtroTexto);
    }).toList();
  }

  List<Conductor> get conductoresFiltrados {
    if (_filtroTexto.isEmpty) return _conductores;
    return _conductores.where((c) {
      return c.codigo.toLowerCase().contains(_filtroTexto) ||
          c.nombres.toLowerCase().contains(_filtroTexto) ||
          c.apellidos.toLowerCase().contains(_filtroTexto) ||
          c.dni.contains(_filtroTexto) ||
          c.licenciaNumero.toLowerCase().contains(_filtroTexto);
    }).toList();
  }

  // Unidades disponibles para nuevo despacho
  List<Unidad> get unidadesDisponiblesParaDespacho {
    return _unidades.where((u) => u.estado == 'enAnden').toList();
  }

  // Conductores disponibles para nuevo despacho (DESCANSADO y no vencido)
  List<Conductor> get conductoresDisponiblesParaDespacho {
    return _conductores.where((c) => c.estado == 'DESCANSADO' && !c.licenciaVencida).toList();
  }

  Future<void> registrarUnidad(Unidad unidad) async {
    await _repository.registrarUnidad(unidad);
    await cargarFlota();
  }

  Future<void> actualizarUnidad(Unidad unidad) async {
    await _repository.actualizarUnidad(unidad);
    await cargarFlota();
  }

  Future<void> darDeBajaUnidad(String id) async {
    await _repository.darDeBajaUnidad(id);
    await cargarFlota();
  }

  Future<void> registrarConductor(Conductor conductor) async {
    await _repository.registrarConductor(conductor);
    await cargarFlota();
  }

  Future<void> actualizarConductor(Conductor conductor) async {
    await _repository.actualizarConductor(conductor);
    await cargarFlota();
  }

  Future<void> darDeBajaConductor(String id) async {
    await _repository.darDeBajaConductor(id);
    await cargarFlota();
  }
}
