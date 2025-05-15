import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class LocalDbHelper {
  static Database? _db;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'tasksv2.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebaseId TEXT,
            title TEXT,
            description TEXT,
            status TEXT,
            createdDate TEXT,
            priority INTEGER,
            category TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertTask(Task task) async {
    return await _db!.insert('tasks', task.toMap());
  }

  static Future<List<Task>> getTasks() async {
    final res = await _db!.query('tasks');
    return res.map((e) => Task.fromMap(e)).toList();
  }

  static Future<int> updateTask(Task task) async {
    return await _db!.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteTask(int id) async {
    return await _db!.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAll() async {
    await _db!.delete('tasks');
  }
}
