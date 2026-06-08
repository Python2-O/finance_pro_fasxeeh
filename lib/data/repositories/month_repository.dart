import '../database/database_helper.dart';
import '../models/month_model.dart';
import '../../core/constants/app_constants.dart';

class MonthRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<MonthModel>> getAllMonths() async {
    final rows = await _db.queryWhere(
      AppConstants.tableMonths,
      orderBy: 'year ASC, month_number ASC',
    );
    return rows.map((r) => MonthModel.fromMap(r)).toList();
  }

  Future<MonthModel?> getMonthById(int id) async {
    final rows = await _db.queryWhere(
      AppConstants.tableMonths,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return MonthModel.fromMap(rows.first);
  }

  Future<int> createMonth(MonthModel month) async {
    return _db.insert(AppConstants.tableMonths, month.toMap());
  }

  Future<bool> monthExists(int year, int monthNumber) async {
    final rows = await _db.queryWhere(
      AppConstants.tableMonths,
      where: 'year = ? AND month_number = ?',
      whereArgs: [year, monthNumber],
    );
    return rows.isNotEmpty;
  }

  Future<int> deleteMonth(int id) async {
    return _db.delete(AppConstants.tableMonths, 'id = ?', [id]);
  }
}
