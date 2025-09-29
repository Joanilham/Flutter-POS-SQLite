import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        category TEXT
      )
    ''');

    // Insert some default items
    await db.rawInsert('''
      INSERT INTO items(name, description, price, category)
      VALUES
        ('Nasi Goreng', 'Nasi goreng spesial dengan telur dan ayam', 25000, 'Makanan'),
        ('Mie Goreng', 'Mie goreng spesial dengan telur dan ayam', 22000, 'Makanan'),
        ('Es Teh Manis', 'Teh manis dingin', 5000, 'Minuman'),
        ('Jus Jeruk', 'Jus jeruk segar', 10000, 'Minuman')
    ''');

    await db.execute('''
      CREATE TABLE txns(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL,
        datetime TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE txn_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        txn_id INTEGER,
        item_id INTEGER,
        quantity INTEGER,
        FOREIGN KEY (txn_id) REFERENCES txns(id),
        FOREIGN KEY (item_id) REFERENCES items(id)
      )
    ''');
  }
}