import '../database/database_helper.dart';
import '../models/loan_model.dart';
import '../../core/constants/app_constants.dart';

class LoanRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<LoanModel>> getAllLoans() async {
    final rows = await _db.queryWhere(
      AppConstants.tableLoans,
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => LoanModel.fromMap(r)).toList();
  }

  Future<List<LoanModel>> getBorrowedLoans() async {
    final rows = await _db.queryWhere(
      AppConstants.tableLoans,
      where: "type = ?",
      whereArgs: ['borrowed'],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => LoanModel.fromMap(r)).toList();
  }

  Future<List<LoanModel>> getLentLoans() async {
    final rows = await _db.queryWhere(
      AppConstants.tableLoans,
      where: "type = ?",
      whereArgs: ['lent'],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => LoanModel.fromMap(r)).toList();
  }

  Future<double> getTotalPendingBorrowed() async {
    final rows = await _db.rawQuery(
      "SELECT SUM(original_amount - paid_or_received) as total FROM ${AppConstants.tableLoans} WHERE type = 'borrowed' AND is_settled = 0",
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalPendingLent() async {
    final rows = await _db.rawQuery(
      "SELECT SUM(original_amount - paid_or_received) as total FROM ${AppConstants.tableLoans} WHERE type = 'lent' AND is_settled = 0",
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> addLoan(LoanModel loan) async {
    return _db.insert(AppConstants.tableLoans, loan.toMap());
  }

  Future<int> updateLoan(LoanModel loan) async {
    return _db.update(
      AppConstants.tableLoans,
      loan.toMap(),
      'id = ?',
      [loan.id],
    );
  }

  Future<int> deleteLoan(int id) async {
    return _db.delete(AppConstants.tableLoans, 'id = ?', [id]);
  }

  Future<int> settleLoan(int id) async {
    return _db.update(
      AppConstants.tableLoans,
      {'is_settled': 1},
      'id = ?',
      [id],
    );
  }
}
