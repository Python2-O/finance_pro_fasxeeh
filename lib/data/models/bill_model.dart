class BillModel {
  final int? id;
  final int monthId;
  final String category;
  final double amount;
  final String? remarks;
  final String createdAt;

  BillModel({
    this.id,
    required this.monthId,
    required this.category,
    required this.amount,
    this.remarks,
    required this.createdAt,
  });

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      monthId: map['month_id'] as int,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      remarks: map['remarks'] as String?,
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
      'created_at': createdAt,
    };
  }

  BillModel copyWith({
    int? id,
    int? monthId,
    String? category,
    double? amount,
    String? remarks,
    String? createdAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
