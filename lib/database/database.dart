import 'package:sqflite/sqflite.dart';
import 'package:mindmap_assessment/models/money_transfer.dart' as mtModel;

class TransactionDatabase {
  static final TransactionDatabase instance = TransactionDatabase._internal();

  static Database? _database;

  TransactionDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/transactions.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  final String TABLE_NAME = "Transactions";
  final String id = "id";
  final String createdAt = "createdAt";
  final String amount = "amount";
  final String userId = "userId";

  Future<void> _createDatabase(Database db, int version) async {
    return await db.execute('''
        CREATE TABLE $TABLE_NAME (
          $id INTEGER PRIMARY KEY AUTOINCREMENT,
          $userId TEXT NOT NULL,
          $amount TEXT NOT NULL,
          $createdAt DATETIME NOT NULL
        )
      ''');
  }

  Future<void> create(List<mtModel.Transaction> transactions) async {
    final db = await instance.database;
    for(mtModel.Transaction transaction in transactions){
      await db.insert(TABLE_NAME, transaction.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<mtModel.Transaction>> getTransactions() async {
    final db = await instance.database;
    var orderBy = '$createdAt DESC';
    final result = await db.query(TABLE_NAME, orderBy: orderBy);
    return result.map((json) => mtModel.Transaction.fromJson(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      TABLE_NAME,
      where: '',
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}