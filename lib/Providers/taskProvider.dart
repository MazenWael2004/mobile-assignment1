import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_operations.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;
  List<Task> get tasks => _tasks;
  List<Task> get favoriteTasks => _tasks.where((task) => task.isFavorite == 1).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners(); //tells the UI to show a loading spinner
    _tasks = await DatabaseHelper.instance.getTasks();
    _isLoading = false;
    notifyListeners(); // tells the UI to rebuild with the new list
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    await fetchTasks(); //refresh the list
  }
  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    await fetchTasks();
  }
  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    await fetchTasks();
  }
  Future<void> toggleFavorite(Task task) async {
    task.isFavorite = task.isFavorite == 1 ? 0 : 1;
    await updateTask(task);
  }
}