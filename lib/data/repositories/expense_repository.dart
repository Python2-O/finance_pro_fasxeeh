import '../database/database_helper.dart';
import '../models/expense_model.dart';
import '../models/bill_model.dart';
import '../../core/constants/app_constants.dart';

class ExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ─── Daily Expenses ────────────────────────────────────────────────────────

  Future<List<ExpenseModel>> getExpensesForMonth(int monthId) async {
    final rows = await _db.queryWhere(
      AppConstants.tableExpenses,
      where: 'month_id = ?',
      whereArgs: [monthId],
      orderBy: 'day ASC',
    );
    return rows.map((r) => ExpenseModel.fromMap(r)).toList();
  }

  Future<double> getTotalExpensesForMonth(int monthId) async {
    final rows = await _db.rawQuery(
      'SELECT SUM(amount) as total FROM ${AppConstants.tableExpenses} WHERE month_id = ?',
      [monthId],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> addExpense(ExpenseModel expense) async {
    return _db.insert(AppConstants.tableExpenses, expense.toMap());
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    return _db.update(
      AppConstants.tableExpenses,
      expense.toMap(),
      'id = ?',
      [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    return _db.delete(AppConstants.tableExpenses, 'id = ?', [id]);
  }

  Future<Map<String, double>> getExpensesByCategoryForMonth(int monthId) async {
    final rows = await _db.rawQuery(
      'SELECT category, SUM(amount) as total FROM ${AppConstants.tableExpenses} WHERE month_id = ? GROUP BY category',
      [monthId],
    );
    final result = <String, double>{};
    for (final row in rows) {
      result[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return result;
  }

  Future<List<ExpenseModel>> getRecentExpenses(int monthId, {int limit = 10}) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM ${AppConstants.tableExpenses} WHERE month_id = ? ORDER BY date DESC, id DESC LIMIT ?',
      [monthId, limit],
    );
    return rows.map((r) => ExpenseModel.fromMap(r)).toList();
  }

  // ─── Bills ─────────────────────────────────────────────────────────────────

  Future<List<BillModel>> getBillsForMonth(int monthId) async {
    final rows = await _db.queryWhere(
      AppConstants.tableBills,
      where: 'month_id = ?',
      whereArgs: [monthId],
    );
    return rows.map((r) => BillModel.fromMap(r)).toList();
  }

  Future<double> getTotalBillsForMonth(int monthId) async {
    final rows = await _db.rawQuery(
      'SELECT SUM(amount) as total FROM ${AppConstants.tableBills} WHERE month_id = ?',
      [monthId],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> addBill(BillModel bill) async {
    return _db.insert(AppConstants.tableBills, bill.toMap());
  }

  Future<int> updateBill(BillModel bill) async {
    return _db.update(
      AppConstants.tableBills,
      bill.toMap(),
      'id = ?',
      [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    return _db.delete(AppConstants.tableBills, 'id = ?', [id]);
  }

  // ─── Combined ─────────────────────────────────────────────────────────────

  Future<double> getTotalAllExpensesForMonth(int monthId) async {
    final expenses = await getTotalExpensesForMonth(monthId);
    final bills = await getTotalBillsForMonth(monthId);
    return expenses + bills;
  }

  Future<List<Map<String, dynamic>>> getAllMonthlyExpenseSummary() async {
    return _db.rawQuery('''
      SELECT m.id, m.name, m.year, m.month_number,
             COALESCE(SUM(e.amount), 0) as daily_expenses,
             COALESCE((SELECT SUM(b.amount) FROM ${AppConstants.tableBills} b WHERE b.month_id = m.id), 0) as bills
      FROM ${AppConstants.tableMonths} m
      LEFT JOIN ${AppConstants.tableExpenses} e ON m.id = e.month_id
      GROUP BY m.id
      ORDER BY m.year ASC, m.month_number ASC
    ''');
  }
}
