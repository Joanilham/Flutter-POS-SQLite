import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user.dart';
import '../models/item.dart'; // Import the Item model
import '../models/txn.dart'; // Import the Txn model
import 'app_db.dart';

class Repo {
  Repo._internal();
  static final Repo instance = Repo._internal();

  Future<User?> login(String username, String password) async {
    final db = await AppDatabase.instance.database;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> register(User user) async {
    final db = await AppDatabase.instance.database;
    final hashedPassword = sha256
        .convert(utf8.encode(user.password!))
        .toString();
    user.password = hashedPassword;

    try {
      final id = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      if (id > 0) {
        user.id = id;
        return user;
      }
    } catch (e) {
      print('Error registering user: $e');
    }
    return null;
  }

  Future<List<Item>> getAllItems() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

   Future<List<Item>> searchItems(String keyword) async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<int> createTransaction(Txn txn) async {
    final db = await AppDatabase.instance.database;
    return await db.transaction((txnDb) async {
      final txnId = await txnDb.insert('txns', txn.toMap());
      for (var detail in txn.details) {
        detail.txnId = txnId;
        await txnDb.insert('txn_details', detail.toMap());
      }
      return txnId;
    });
  }

    Future<void> deleteTxn(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('txns', where: 'id = ?', whereArgs: [id]);
    await db.delete('txn_details', where: 'txn_id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getDailyTransactionTotals() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m-%d', datetime) as date, 
        SUM(total) as daily_total
      FROM txns
      GROUP BY date
      ORDER BY date DESC
    ''');

    return {
      for (var row in result)
        row['date'] as String: (row['daily_total'] as num).toDouble()
    };
  }
}