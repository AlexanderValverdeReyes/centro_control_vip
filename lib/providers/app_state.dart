import 'package:flutter/material.dart';
import '../models/bus.dart';

class AppState extends ChangeNotifier {
  int _currentMenuIndex = 0;
  int get currentMenuIndex => _currentMenuIndex;

  void setMenuIndex(int index) {
    _currentMenuIndex = index;
    notifyListeners();
  }

  // Mock Data
  List<Bus> buses = [
    Bus(id: 'BUS-VIP-101', route: 'LIMA - TRUJILLO', operator: 'OP-629', status: 'EN ANDÉN', eta: '00:15:00'),
    Bus(id: 'BUS-VIP-102', route: 'LIMA - CHICLAYO', operator: 'OP-112', status: 'EN RUTA', eta: '04:30:00'),
    Bus(id: 'BUS-VIP-103', route: 'LIMA - ICA', operator: 'OP-992', status: 'NOVEDADES', eta: 'RETRASO 20M'),
    Bus(id: 'BUS-VIP-204', route: 'LIMA - AREQUIPA', operator: 'OP-331', status: 'EN RUTA', eta: '12:00:00'),
  ];
}
