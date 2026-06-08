import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  List<BillModel> _bills = [];
  double _totalExpenses = 0;
  double _totalBills = 0;
  Map<String, double> _byCategory = {};
  List<ExpenseModel> _recentExpenses = [];
  bool _isLoading = false;
  int? _currentMonthId;

  List<ExpenseModel> get expenses => _expenses;
  List<BillModel> get bills => _bills;
  double get totalExpenses => _totalExpenses;
  double get totalBills => _totalBills;
  double get totalAllExpenses => _totalExpenses + _totalBills;
  Map<String, double> get byCategory => _byCategory;
  List<ExpenseModel> get recentExpenses => _recentExpenses;
  bool get isLoading => _isLoading;

  Future<void> loadForMonth(int monthId) async {
    if (_currentMonthId == monthId && _expenses.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    _currentMonthId = monthId;
    await _reload(monthId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reload(int monthId) async {
    _expenses = await _repo.getExpensesForMonth(monthId);
    _bills = await _repo.getBillsForMonth(monthId);
    _totalExpenses = await _repo.getTotalExpensesForMonth(monthId);
    _totalBills = await _repo.getTotalBillsForMonth(monthId);
    _byCategory = await _repo.getExpensesByCategoryForMonth(monthId);
    _recentExpenses = await _repo.getRecentExpenses(monthId);
  }

  Future<void> refresh() async {
    if (_currentMonthId == null) return;
    await _reload(_currentMonthId!);
    notifyListeners();
  }

  // Expenses
  Future<void> addExpense(ExpenseModel expense) async {
    await _repo.addExpense(expense);
    await refresh();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _repo.updateExpense(expense);
    await refresh();
  }

  Future<void> deleteExpense(int id) async {
    await _repo.deleteExpense(id);
    await refresh();
  }

  // Bills
  Future<void> addBill(BillModel bill) async {
    await _repo.addBill(bill);
    await refresh();
  }

  Future<void> updateBill(BillModel bill) async {
    await _repo.updateBill(bill);
    await refresh();
  }

  Future<void> deleteBill(int id) async {
    await _repo.deleteBill(id);
    await refresh();
  }

  Future<List<Map<String, dynamic>>> getAllMonthlyExpenseSummary() {
    return _repo.getAllMonthlyExpenseSummary();
  }

  void clearForMonth() {
    _expenses = [];
    _bills = [];
    _totalExpenses = 0;
    _totalBills = 0;
    _byCategory = {};
    _recentExpenses = [];
    _currentMonthId = null;
    notifyListeners();
  }
}
