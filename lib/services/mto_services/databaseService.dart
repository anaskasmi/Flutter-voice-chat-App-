import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final _databaseName = "MyTaxiOffice.db";
  static final _databaseVersion = 1;

  static final table = 'voice_messages';

  static final columnId = 'id';
  static final columnDurationInSec = 'durationInSec';
  static final columnOwnerId = 'ownerId';
  static final columnFullName = 'ownerFullName';
  static final columnUrl = 'url';
  static final columnCreatedAt = 'createdAt';
  static final columnPictureUrl = 'pictureUrl';

  // make this a singleton class
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnDurationInSec INTEGER NOT NULL,
            $columnOwnerId TEXT NOT NULL,
            $columnFullName TEXT NOT NULL,
            $columnUrl TEXT NOT NULL,
            $columnCreatedAt INTEGER NOT NULL,
            $columnPictureUrl TEXT)
          ''');
  }

  // SQL code to delete the database table
  Future deleteTable() async {
    Database db = await instance.database;
    await db.execute('''
          DROP TABLE IF EXISTS $table
          ''');
    print("table droped");
  }

  // SQL code to create the database table
  Future createTable() async {
    Database db = await instance.database;
    await db.execute('''
         CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnDurationInSec INTEGER NOT NULL,
            $columnOwnerId TEXT NOT NULL,
            $columnFullName TEXT NOT NULL,
            $columnUrl TEXT NOT NULL,
            $columnCreatedAt INTEGER NOT NULL,
            $columnPictureUrl TEXT)
          ''');
    print("table created");
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
    // try {
    // } catch (e) {
    //   print("error inseting : " + e.message);
    //   return 0;
    // }
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    try {
      return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'));
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<List<Map<String, dynamic>>> queryLastAddedRow() async {
    Database db = await instance.database;
    try {
      return await db.query('$table ORDER BY $columnId DESC LIMIT 1');
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
