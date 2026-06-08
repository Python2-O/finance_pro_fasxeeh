class ExpenseModel {
  final int? id;
  final int monthId;
  final String category;
  final String? subCategory;
  final double amount;
  final int day;
  final String date;
  final String? remarks;
  final String createdAt;

  ExpenseModel({
    this.id,
    required this.monthId,
    required this.category,
    this.subCategory,
    required this.amount,
    required this.day,
    required this.date,
    this.remarks,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      monthId: map['month_id'] as int,
      category: map['category'] as String,
      subCategory: map['sub_category'] as String?,
      amount: (map['amount'] as num).toDouble(),
      day: map['day'] as int,
      date: map['date'] as String,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'month_id': monthId,
      'category': category,
      'sub_category': subCategory,
      'amount': amount,
      'day': day,
      'date': date,
      'remarks': remarks,
      'created_at': createdAt,
    };
  }

  ExpenseModel copyWith({
    int? id,
    int? monthId,
    String? category,
    String? subCategory,
    double? amount,
    int? day,
    String? date,
    String? remarks,
    String? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      amount: amount ?? this.amount,
      day: day ?? this.day,
      date: date ?? this.date,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
