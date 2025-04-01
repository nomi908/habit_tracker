import 'package:habit_tracker/model/habit_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static Database? _database;

  static Future<Database> get getdatabase async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'habits_tracker.db');

    return await openDatabase(path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE habits_tracker(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0
        )''');
      },
    );
  }



  //create habit
  static Future<int> insertHabit(HabitModel habitmodel) async{
    final db = await getdatabase;
    return await db.insert('habits_tracker', habitmodel.toJson());
  }

  //update habit
  static Future<int> updateHabit(HabitModel habitmodel) async{
    final db = await getdatabase;
    return await db.update('habits_tracker', habitmodel.toJson(),where: 'id=?',whereArgs: [habitmodel.id]);
  }

  //delete habit
  static Future<int> deleteHabit(int id) async{
    final db = await getdatabase;
    return await db.delete('habits_tracker',where: 'id=?',whereArgs: [id]);
  }

  static Future<void> deleteSelectedHabits(List<bool> selectedItems, List<HabitModel> habits) async {
    final db = await getdatabase;
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        await db.delete('habits_tracker', where: 'id = ?', whereArgs: [habits[i].id]);
      }

    }
  }

  //get all habits
  static Future<List<HabitModel>> getAllHabits() async{
    final db = await getdatabase;
    final List<Map<String,dynamic>> maps = await db.query('habits_tracker', orderBy: 'id DESC');
    return maps.map((map) => HabitModel.fromJson(map)).toList();
  }



}

