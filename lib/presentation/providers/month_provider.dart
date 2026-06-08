import 'package:flutter/material.dart';
import '../../data/models/month_model.dart';
import '../../data/repositories/month_repository.dart';
import '../../core/constants/app_constants.dart';

class MonthProvider extends ChangeNotifier {
  final MonthRepository _repo = MonthRepository();

  List<MonthModel> _months = [];
  MonthModel? _selectedMonth;
  bool _isLoading = false;

  List<MonthModel> get months => _months;
  MonthModel? get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  MonthProvider() {
    loadMonths();
  }

  Future<void> loadMonths() async {
    _isLoading = true;
    notifyListeners();
    _months = await _repo.getAllMonths();
    if (_months.isNotEmpty && _selectedMonth == null) {
      _selectedMonth = _months.last;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectMonth(MonthModel month) {
    _selectedMonth = month;
    notifyListeners();
  }

  Future<bool> addMonth(String name, int year, int monthNumber) async {
    final exists = await _repo.monthExists(year, monthNumber);
    if (exists) return false;
    final month = MonthModel(
      name: name,
      year: year,
      monthNumber: monthNumber,
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await _repo.createMonth(month);
    final created = await _repo.getMonthById(id);
    if (created != null) {
      _months.add(created);
      _months.sort((a, b) {
        final yearCmp = a.year.compareTo(b.year);
        return yearCmp != 0 ? yearCmp : a.monthNumber.compareTo(b.monthNumber);
      });
      _selectedMonth = created;
      notifyListeners();
    }
    return true;
  }

  Future<void> deleteMonth(int id) async {
    await _repo.deleteMonth(id);
    _months.removeWhere((m) => m.id == id);
    if (_selectedMonth?.id == id) {
      _selectedMonth = _months.isNotEmpty ? _months.last : null;
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> getAvailableMonthsToAdd() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final currentYear = DateTime.now().year;
    final result = <Map<String, dynamic>>[];
    for (int year = 2025; year <= currentYear + 1; year++) {
      for (int m = 1; m <= 12; m++) {
        final exists = _months.any((mo) => mo.year == year && mo.monthNumber == m);
        if (!exists) {
          result.add({
            'name': monthNames[m - 1],
            'year': year,
            'month_number': m,
          });
        }
      }
    }
    return result;
  }
}
