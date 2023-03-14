import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class DatabaseHelper {
  static const _databaseName = "pocket_vocabulary.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE Category (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE Word (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fromLanguage TEXT,
            toLanguage TEXT,
            originalText TEXT,
            translatedText TEXT,
            categoryId INTEGER,
            FOREIGN KEY (categoryId)
              REFERENCES Category (id)
          )
          ''');
  }

  // Category CRUD methods

  Future<int> insertCategory(WordCategoryDTO category) async {
    final db = await database;

    var res = await db?.insert(
      'Category',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (res != null) {
      return res;
    } else {
      return -1;
    }
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;

    await db?.delete(
      'Category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WordCategory>> categories() async {
    final db = await database;

    if (db != null) {
      // Query the table for all The Dogs.
      final List<Map<String, dynamic>> maps = await db.query('Category');

      // Convert the List<Map<String, dynamic> into a List<Dog>.
      return List.generate(maps.length, (i) {
        return WordCategory(
          id: maps[i]['id'],
          name: maps[i]['name'],
        );
      });
    } else {
      return List.empty();
    }
  }

  Future<WordCategory?> getCategoryById(int id) async {
    final db = await database;

    if (db != null) {
      final List<Map<String, dynamic>> res = await db.query('Category',
          where: 'id = ?', whereArgs: [id], limit: 1);
      var first = res.first;

      return WordCategory(
        id: first['id'],
        name: first['name'],
      );
    } else {
      return null;
    }
  }

  // Words CRUD methods
  Future<int> insertWord(WordDTO word) async {
    final db = await database;

    var res = await db?.insert(
      'Word',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (res != null) {
      return res;
    } else {
      return -1;
    }
  }

  Future<void> deleteWord(int id) async {
    final db = await database;

    await db?.delete(
      'Word',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Word>> words() async {
    final db = await database;

    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('Word');

      return List.generate(maps.length, (i) {
        return Word(
          id: maps[i]['id'],
          fromLanguage: maps[i]['fromLanguage'],
          toLanguage: maps[i]['toLanguage'],
          originalText: maps[i]['originalText'],
          translatedText: maps[i]['translatedText'],
          categoryId: maps[i]['categoryId'],
        );
      });
    } else {
      return List.empty();
    }
  }

  Future<List<Word>> wordsByCategory(WordCategory category) async {
    int categoryId = category.id;
    final db = await database;

    if (db != null) {
      final List<Map<String, dynamic>> maps = await db
          .query('Category', where: 'categoryId = ?', whereArgs: [categoryId]);

      return List.generate(maps.length, (i) {
        return Word(
          id: maps[i]['id'],
          fromLanguage: maps[i]['fromLanguage'],
          toLanguage: maps[i]['toLanguage'],
          originalText: maps[i]['originalText'],
          translatedText: maps[i]['translatedText'],
          categoryId: maps[i]['categoryId'],
        );
      });
    } else {
      return List.empty();
    }
  }

  Future<Word?> getWordById(int id) async {
    final db = await database;

    if (db != null) {
      final List<Map<String, dynamic>> res =
          await db.query('Word', where: 'id = ?', whereArgs: [id], limit: 1);
      var first = res.first;

      return Word(
        id: first['id'],
        fromLanguage: first['fromLanguage'],
        toLanguage: first['toLanguage'],
        originalText: first['originalText'],
        translatedText: first['translatedText'],
        categoryId: first['categoryId'],
      );
    } else {
      return null;
    }
  }
}
