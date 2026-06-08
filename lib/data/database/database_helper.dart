import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Months table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMonths} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        year INTEGER NOT NULL,
        month_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(year, month_number)
      )
    ''');

    // Income table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableIncome} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        remarks TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (month_id) REFERENCES ${AppConstants.tableMonths}(id) ON DELETE CASCADE
      )
    ''');

    // Expenses table (daily transactions)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableExpenses} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT,
        amount REAL NOT NULL DEFAULT 0,
        day INTEGER NOT NULL,
        date TEXT NOT NULL,
        remarks TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (month_id) REFERENCES ${AppConstants.tableMonths}(id) ON DELETE CASCADE
      )
    ''');

    // Bills table (monthly fixed bills)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBills} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        remarks TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (month_id) REFERENCES ${AppConstants.tableMonths}(id) ON DELETE CASCADE
      )
    ''');

    // Loans table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLoans} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL CHECK(type IN ('borrowed', 'lent')),
        person TEXT NOT NULL,
        original_amount REAL NOT NULL,
        paid_or_received REAL NOT NULL DEFAULT 0,
        date TEXT,
        remarks TEXT,
        is_settled INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed initial data
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Seed months
    for (final month in AppConstants.seedMonths) {
      await db.insert(AppConstants.tableMonths, {
        ...month,
        'created_at': now,
      });
    }

    // Get June month id
    final juneRows = await db.query(
      AppConstants.tableMonths,
      where: 'name = ?',
      whereArgs: ['June'],
    );
    if (juneRows.isEmpty) return;
    final juneId = juneRows.first['id'] as int;
    final juneDate = '2025-06-01';

    // Seed June income
    final juneData = AppConstants.juneData;
    final incomeMap = {
      'Salary': (juneData['salary'] as double),
      'OT': (juneData['ot'] as double),
      'Extra Income': (juneData['extra_income'] as double),
    };
    for (final entry in incomeMap.entries) {
      if (entry.value > 0) {
        await db.insert(AppConstants.tableIncome, {
          'month_id': juneId,
          'category': entry.key,
          'amount': entry.value,
          'remarks': entry.key == 'Extra Income' ? 'Lent from Hasnain' : null,
          'date': juneDate,
          'created_at': now,
        });
      }
    }

    // Seed June bills
    final bills = juneData['bills'] as Map<String, dynamic>;
    for (final entry in bills.entries) {
      if ((entry.value as double) > 0) {
        await db.insert(AppConstants.tableBills, {
          'month_id': juneId,
          'category': entry.key,
          'amount': entry.value,
          'remarks': null,
          'created_at': now,
        });
      }
    }

    // Seed June daily expenses
    final dailyExpenses = juneData['daily_expenses'] as List;
    for (final exp in dailyExpenses) {
      final expMap = exp as Map<String, dynamic>;
      final day = expMap['day'] as int;
      final dateStr = day <= 15 ? '2025-07-$day' : '2025-06-$day';

      if ((expMap['food'] as double) > 0) {
        await db.insert(AppConstants.tableExpenses, {
          'month_id': juneId,
          'category': 'Food',
          'sub_category': 'Food',
          'amount': expMap['food'],
          'day': day,
          'date': dateStr,
          'remarks': expMap['remarks'],
          'created_at': now,
        });
      }
      if ((expMap['misc'] as double) > 0) {
        await db.insert(AppConstants.tableExpenses, {
          'month_id': juneId,
          'category': 'Miscellaneous',
          'sub_category': 'Miscellaneous',
          'amount': expMap['misc'],
          'day': day,
          'date': dateStr,
          'remarks': expMap['remarks'],
          'created_at': now,
        });
      }
      if ((expMap['transport_in'] as double) > 0) {
        await db.insert(AppConstants.tableExpenses, {
          'month_id': juneId,
          'category': 'Transport',
          'sub_category': 'Transport IN',
          'amount': expMap['transport_in'],
          'day': day,
          'date': dateStr,
          'remarks': expMap['remarks'],
          'created_at': now,
        });
      }
      if ((expMap['transport_out'] as double) > 0) {
        await db.insert(AppConstants.tableExpenses, {
          'month_id': juneId,
          'category': 'Transport',
          'sub_category': 'Transport OUT',
          'amount': expMap['transport_out'],
          'day': day,
          'date': dateStr,
          'remarks': expMap['remarks'],
          'created_at': now,
        });
      }
    }

    // Seed Loans - Borrowed
    for (final loan in AppConstants.borrowedLoans) {
      await db.insert(AppConstants.tableLoans, {
        'type': 'borrowed',
        'person': loan['person'],
        'original_amount': loan['amount'],
        'paid_or_received': loan['paid'],
        'date': null,
        'remarks': loan['remarks'],
        'is_settled': 0,
        'created_at': now,
      });
    }

    // Seed Loans - Lent
    for (final loan in AppConstants.lentLoans) {
      await db.insert(AppConstants.tableLoans, {
        'type': 'lent',
        'person': loan['person'],
        'original_amount': loan['amount'],
        'paid_or_received': loan['received'],
        'date': null,
        'remarks': loan['remarks'],
        'is_settled': 0,
        'created_at': now,
      });
    }
  }

  // ─── Generic CRUD ────────────────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }
}
