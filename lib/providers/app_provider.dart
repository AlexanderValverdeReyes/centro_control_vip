import 'dart:async';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _currentTimeString = '00:00:00';
  String _searchQuery = '';
  late Timer _timer;

  int get currentIndex => _currentIndex;
  String get currentTimeString => _currentTimeString;
  String get searchQuery => _searchQuery;

  AppProvider() {
    _updateClock();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    _currentTimeString = '$h:$m:$s';
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
