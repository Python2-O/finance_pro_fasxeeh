import '../database/database_helper.dart';
import '../models/income_model.dart';
import '../../core/constants/app_constants.dart';

class IncomeRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<IncomeModel>> getIncomeForMonth(int monthId) async {
    final rows = await _db.queryWhere(
      AppConstants.tableIncome,
      where: 'month_id = ?',
      whereArgs: [monthId],
      orderBy: 'date ASC',
    );
    return rows.map((r) => IncomeModel.fromMap(r)).toList();
  }

  Future<double> getTotalIncomeForMonth(int monthId) async {
    final rows = await _db.rawQuery(
      'SELECT SUM(amount) as total FROM ${AppConstants.tableIncome} WHERE month_id = ?',
      [monthId],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> addIncome(IncomeModel income) async {
    return _db.insert(AppConstants.tableIncome, income.toMap());
  }

  Future<int> updateIncome(IncomeModel income) async {
    return _db.update(
      AppConstants.tableIncome,
      income.toMap(),
      'id = ?',
      [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    return _db.delete(AppConstants.tableIncome, 'id = ?', [id]);
  }

  Future<Map<String, double>> getIncomeByCategoryForMonth(int monthId) async {
    final rows = await _db.rawQuery(
      'SELECT category, SUM(amount) as total FROM ${AppConstants.tableIncome} WHERE month_id = ? GROUP BY category',
      [monthId],
    );
    final result = <String, double>{};
    for (final row in rows) {
      result[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllMonthlyIncomeSummary() async {
    return _db.rawQuery('''
      SELECT m.id, m.name, m.year, m.month_number,
             COALESCE(SUM(i.amount), 0) as total_income
      FROM ${AppConstants.tableMonths} m
      LEFT JOIN ${AppConstants.tableIncome} i ON m.id = i.month_id
      GROUP BY m.id
      ORDER BY m.year ASC, m.month_number ASC
    ''');
  }
}
