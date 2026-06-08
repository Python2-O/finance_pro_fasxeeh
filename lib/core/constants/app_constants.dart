class AppConstants {
  static const String appName = 'Finance Pro';
  static const String appSubtitle = 'FasXeeH';
  static const String currency = 'PKR';
  static const String currencySymbol = '₨';

  // Secure Storage Keys
  static const String pinKey = 'finance_pro_pin';
  static const String biometricKey = 'finance_pro_biometric';
  static const String themeKey = 'finance_pro_theme';

  // Database
  static const String dbName = 'finance_pro.db';
  static const int dbVersion = 1;

  // Table Names
  static const String tableMonths = 'months';
  static const String tableIncome = 'income';
  static const String tableExpenses = 'expenses';
  static const String tableBills = 'bills';
  static const String tableLoans = 'loans';

  // Income Categories
  static const List<String> defaultIncomeCategories = [
    'Salary',
    'OT',
    'Extra Income',
    'Freelance',
    'Business',
    'Investment',
    'Other',
  ];

  // Expense Categories
  static const List<String> defaultExpenseCategories = [
    'Food',
    'Transport',
    'Miscellaneous',
    'Shopping',
    'Healthcare',
    'Education',
    'Entertainment',
    'Other',
  ];

  // Bill Categories
  static const List<String> defaultBillCategories = [
    'Grocery',
    'Electricity',
    'Drinking Water',
    'Loan Repayment',
    'Mobile Recharge',
    'Wifi',
    'Wife',
    'Miscellaneous',
  ];

  // Pre-seeded months from Excel
  static const List<Map<String, dynamic>> seedMonths = [
    {'name': 'June', 'year': 2025, 'month_number': 6},
    {'name': 'July', 'year': 2025, 'month_number': 7},
    {'name': 'August', 'year': 2025, 'month_number': 8},
  ];

  // June seed data from Excel
  static const Map<String, dynamic> juneData = {
    'salary': 74630.0,
    'ot': 0.0,
    'extra_income': 10000.0,
    'bills': {
      'Grocery': 16000.0,
      'Electricity': 0.0,
      'Drinking Water': 0.0,
      'Loan Repayment': 15750.0,
      'Mobile Recharge': 0.0,
      'Wifi': 2000.0,
      'Wife': 8463.0,
      'Miscellaneous': 0.0,
    },
    'daily_expenses': [
      {'day': 26, 'food': 0.0, 'misc': 21000.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': 'Repayment Chacha 10000 + 3000 Lent to Qadir + 8000 Meal expense for Funeral'},
      {'day': 27, 'food': 0.0, 'misc': 10000.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': '8000 (Wife) + 1600 Suit Stiching Price'},
      {'day': 28, 'food': 0.0, 'misc': 500.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': ''},
      {'day': 29, 'food': 0.0, 'misc': 500.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': ''},
      {'day': 30, 'food': 0.0, 'misc': 500.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': ''},
      {'day': 31, 'food': 0.0, 'misc': 500.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': ''},
      {'day': 1, 'food': 0.0, 'misc': 3100.0, 'transport_in': 0.0, 'transport_out': 0.0, 'remarks': 'Cake Expense Sameer and Mine'},
    ],
  };

  // Loan seed data from Excel
  static const List<Map<String, dynamic>> borrowedLoans = [
    {'person': 'Chaveet', 'amount': 4700.0, 'paid': 0.0, 'remarks': ''},
    {'person': 'Hasnain', 'amount': 10000.0, 'paid': 0.0, 'remarks': ''},
  ];

  static const List<Map<String, dynamic>> lentLoans = [
    {'person': 'Hasnain', 'amount': 1000.0, 'received': 0.0, 'remarks': 'FAN'},
    {'person': 'Abbas', 'amount': 1600.0, 'received': 0.0, 'remarks': 'Salary per dega'},
  ];
}
