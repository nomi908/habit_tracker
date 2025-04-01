import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/db/local_db.dart';
import 'package:habit_tracker/model/habit_model.dart';

class HabitProvider extends ChangeNotifier {

  List<HabitModel> _habits = [];
  List<bool> isSelected = [];

  List<HabitModel> get habits => _habits;

  Future<void> loadHabits() async{
    _habits = await LocalDB.getAllHabits();
    print("Loaded Habits: $_habits");
    notifyListeners();
  }


  Future<void> addHabit(String title) async{
    final newHabit = HabitModel(title: title);
    final id = await LocalDB.insertHabit(newHabit);
    newHabit.id = id;
    _habits.add(newHabit);
    print("New habit added: ${newHabit.title}, ID: ${newHabit.id}");  // Debugging line
    await loadHabits();  // This will fetch the latest habits from the database and notify listeners

    notifyListeners();
  }

  Future<void> deleteHabit(int id) async{
    await LocalDB.deleteHabit(id);
    _habits.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> deleteSelectedHabits(List<bool> selectedItems) async{
    await LocalDB.deleteSelectedHabits(selectedItems, _habits);
    _habits.removeWhere((habit) => selectedItems[_habits.indexOf(habit)]);
    notifyListeners();
  }


  Future<void> updateHabitTitle(int id, String newTitle) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index].title = newTitle;
      await LocalDB.updateHabit(_habits[index]);
      notifyListeners(); 
    }
  }

  Future<void> toggleHabit(int id) async{
    final habit = _habits.firstWhere((element) => element.id == id);
    habit.isCompleted = !habit.isCompleted;
    await LocalDB.updateHabit(habit);
    notifyListeners();
  }
}