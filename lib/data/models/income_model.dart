class IncomeModel {
  final int? id;
  final int monthId;
  final String category;
  final double amount;
  final String? remarks;
  final String date;
  final String createdAt;

  IncomeModel({
    this.id,
    required this.monthId,
    required this.category,
    required this.amount,
    this.remarks,
    required this.date,
    required this.createdAt,
  });

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as int?,
      monthId: map['month_id'] as int,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      remarks: map['remarks'] as String?,
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'month_id': monthId,
      'category': category,
      'amount': amount,
      'remarks': remarks,
      'date': date,
      'created_at': createdAt,
    };
  }

  IncomeModel copyWith({
    int? id,
    int? monthId,
    String? category,
    double? amount,
    String? remarks,
    String? date,
    String? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
