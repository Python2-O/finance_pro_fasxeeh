class LoanModel {
  final int? id;
  final String type; // 'borrowed' or 'lent'
  final String person;
  final double originalAmount;
  final double paidOrReceived;
  final String? date;
  final String? remarks;
  final bool isSettled;
  final String createdAt;

  LoanModel({
    this.id,
    required this.type,
    required this.person,
    required this.originalAmount,
    required this.paidOrReceived,
    this.date,
    this.remarks,
    required this.isSettled,
    required this.createdAt,
  });

  double get pending => originalAmount - paidOrReceived;
  bool get isBorrowed => type == 'borrowed';
  bool get isLent => type == 'lent';

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      person: map['person'] as String,
      originalAmount: (map['original_amount'] as num).toDouble(),
      paidOrReceived: (map['paid_or_received'] as num).toDouble(),
      date: map['date'] as String?,
      remarks: map['remarks'] as String?,
      isSettled: (map['is_settled'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'person': person,
      'original_amount': originalAmount,
      'paid_or_received': paidOrReceived,
      'date': date,
      'remarks': remarks,
      'is_settled': isSettled ? 1 : 0,
      'created_at': createdAt,
    };
  }

  LoanModel copyWith({
    int? id,
    String? type,
    String? person,
    double? originalAmount,
    double? paidOrReceived,
    String? date,
    String? remarks,
    bool? isSettled,
    String? createdAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      type: type ?? this.type,
      person: person ?? this.person,
      originalAmount: originalAmount ?? this.originalAmount,
      paidOrReceived: paidOrReceived ?? this.paidOrReceived,
      date: date ?? this.date,
      remarks: remarks ?? this.remarks,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
