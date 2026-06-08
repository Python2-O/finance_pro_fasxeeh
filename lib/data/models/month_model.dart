class MonthModel {
  final int? id;
  final String name;
  final int year;
  final int monthNumber;
  final String createdAt;

  MonthModel({
    this.id,
    required this.name,
    required this.year,
    required this.monthNumber,
    required this.createdAt,
  });

  factory MonthModel.fromMap(Map<String, dynamic> map) {
    return MonthModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      year: map['year'] as int,
      monthNumber: map['month_number'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'year': year,
      'month_number': monthNumber,
      'created_at': createdAt,
    };
  }

  String get displayName => '$name $year';

  @override
  String toString() => displayName;
}
