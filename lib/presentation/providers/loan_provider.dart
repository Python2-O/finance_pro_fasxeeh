import 'package:flutter/material.dart';
import '../../data/models/loan_model.dart';
import '../../data/repositories/loan_repository.dart';

class LoanProvider extends ChangeNotifier {
  final LoanRepository _repo = LoanRepository();

  List<LoanModel> _borrowedLoans = [];
  List<LoanModel> _lentLoans = [];
  double _totalPendingBorrowed = 0;
  double _totalPendingLent = 0;
  bool _isLoading = false;

  List<LoanModel> get borrowedLoans => _borrowedLoans;
  List<LoanModel> get lentLoans => _lentLoans;
  List<LoanModel> get allLoans => [..._borrowedLoans, ..._lentLoans];
  double get totalPendingBorrowed => _totalPendingBorrowed;
  double get totalPendingLent => _totalPendingLent;
  double get netPosition => _totalPendingLent - _totalPendingBorrowed;
  bool get isLoading => _isLoading;

  LoanProvider() {
    loadLoans();
  }

  Future<void> loadLoans() async {
    _isLoading = true;
    notifyListeners();
    await _refresh();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _refresh() async {
    _borrowedLoans = await _repo.getBorrowedLoans();
    _lentLoans = await _repo.getLentLoans();
    _totalPendingBorrowed = await _repo.getTotalPendingBorrowed();
    _totalPendingLent = await _repo.getTotalPendingLent();
  }

  Future<void> addLoan(LoanModel loan) async {
    await _repo.addLoan(loan);
    await _refresh();
    notifyListeners();
  }

  Future<void> updateLoan(LoanModel loan) async {
    await _repo.updateLoan(loan);
    await _refresh();
    notifyListeners();
  }

  Future<void> deleteLoan(int id) async {
    await _repo.deleteLoan(id);
    await _refresh();
    notifyListeners();
  }

  Future<void> settleLoan(int id) async {
    await _repo.settleLoan(id);
    await _refresh();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _refresh();
    notifyListeners();
  }
}
