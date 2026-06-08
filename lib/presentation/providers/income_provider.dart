import 'package:flutter/material.dart';
import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomeRepository _repo = IncomeRepository();

  List<IncomeModel> _incomes = [];
  double _totalIncome = 0;
  Map<String, double> _byCategory = {};
  bool _isLoading = false;
  int? _currentMonthId;

  List<IncomeModel> get incomes => _incomes;
  double get totalIncome => _totalIncome;
  Map<String, double> get byCategory => _byCategory;
  bool get isLoading => _isLoading;

  Future<void> loadForMonth(int monthId) async {
    if (_currentMonthId == monthId && _incomes.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    _currentMonthId = monthId;
    _incomes = await _repo.getIncomeForMonth(monthId);
    _totalIncome = await _repo.getTotalIncomeForMonth(monthId);
    _byCategory = await _repo.getIncomeByCategoryForMonth(monthId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentMonthId == null) return;
    _incomes = await _repo.getIncomeForMonth(_currentMonthId!);
    _totalIncome = await _repo.getTotalIncomeForMonth(_currentMonthId!);
    _byCategory = await _repo.getIncomeByCategoryForMonth(_currentMonthId!);
    notifyListeners();
  }

  Future<void> addIncome(IncomeModel income) async {
    await _repo.addIncome(income);
    await refresh();
  }

  Future<void> updateIncome(IncomeModel income) async {
    await _repo.updateIncome(income);
    await refresh();
  }

  Future<void> deleteIncome(int id) async {
    await _repo.deleteIncome(id);
    await refresh();
  }

  Future<List<Map<String, dynamic>>> getAllMonthlyIncomeSummary() {
    return _repo.getAllMonthlyIncomeSummary();
  }

  void clearForMonth() {
    _incomes = [];
    _totalIncome = 0;
    _byCategory = {};
    _currentMonthId = null;
    notifyListeners();
  }
}
