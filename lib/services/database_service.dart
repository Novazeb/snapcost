import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../features/expenses/data/models/expense_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'snapcost.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        merchant TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        payment_method TEXT NOT NULL,
        raw_ocr TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert sample initial expenses for immediate rich UI demo experience
    final now = DateTime.now();
    await _insertSampleData(db, now);
  }

  Future<void> _insertSampleData(Database db, DateTime now) async {
    final samples = [
      ExpenseModel(
        id: 'exp_1',
        merchant: 'Alfamart',
        amount: 85500,
        categoryId: 'groceries',
        date: now,
        notes: 'Susu, Roti & Camilan',
        payment_method: 'QRIS',
        created_at: now,
      ),
      ExpenseModel(
        id: 'exp_2',
        merchant: 'Starbucks Reserve',
        amount: 68000,
        categoryId: 'food',
        date: now.subtract(const Duration(hours: 4)),
        notes: 'Americano & Muffin',
        payment_method: 'Kartu Kredit',
        created_at: now,
      ),
      ExpenseModel(
        id: 'exp_3',
        merchant: 'Pertamina SPBU 31',
        amount: 250000,
        categoryId: 'transport',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Isi Pertamax Turbo',
        payment_method: 'Cash',
        created_at: now,
      ),
      ExpenseModel(
        id: 'exp_4',
        merchant: 'Tokopedia Tech',
        amount: 499000,
        categoryId: 'shopping',
        date: now.subtract(const Duration(days: 2)),
        notes: 'Kabel Type-C & Powerbank',
        payment_method: 'Transfer Bank',
        created_at: now,
      ),
      ExpenseModel(
        id: 'exp_5',
        merchant: 'PLN Token Listrik',
        amount: 500000,
        categoryId: 'bills',
        date: now.subtract(const Duration(days: 4)),
        notes: 'Tagihan Listrik Rumah',
        payment_method: 'E-Wallet',
        created_at: now,
      ),
      ExpenseModel(
        id: 'exp_6',
        merchant: 'XXI Cinema Grand Indonesia',
        amount: 150000,
        categoryId: 'entertainment',
        date: now.subtract(const Duration(days: 5)),
        notes: 'Tiket Nonton 2x',
        payment_method: 'QRIS',
        created_at: now,
      ),
    ];

    for (final exp in samples) {
      await db.insert('expenses', exp.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // --- CRUD Operations for Expenses ---

  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Settings Persistence ---

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
