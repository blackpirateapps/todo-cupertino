import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../utils/app_utils.dart';

class AppState extends ChangeNotifier {
  AppState._({
    required SharedPreferences preferences,
    required List<Task> tasks,
    required bool isDarkMode,
  }) : _preferences = preferences,
       _tasks = tasks,
       _isDarkMode = isDarkMode;

  static const _tasksKey = 'tasks_v1';
  static const _darkModeKey = 'dark_mode_v1';

  final SharedPreferences _preferences;
  List<Task> _tasks;
  bool _isDarkMode;

  static Future<AppState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawTasks = preferences.getString(_tasksKey);
    final parsedTasks = <Task>[];
    if (rawTasks != null && rawTasks.isNotEmpty) {
      try {
        final list = jsonDecode(rawTasks) as List<dynamic>;
        for (final item in list) {
          parsedTasks.add(Task.fromJson(item as Map<String, dynamic>));
        }
      } catch (_) {
        // Ignore invalid persisted data and start fresh.
      }
    }

    return AppState._(
      preferences: preferences,
      tasks: parsedTasks,
      isDarkMode: preferences.getBool(_darkModeKey) ?? false,
    );
  }

  bool get isDarkMode => _isDarkMode;

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> sortedTasks() {
    final copy = [..._tasks];
    copy.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate != null && b.dueDate != null) {
        final byDue = a.dueDate!.compareTo(b.dueDate!);
        if (byDue != 0) return byDue;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return copy;
  }

  List<Task> tasksDueToday() {
    final now = DateTime.now();
    return sortedTasks()
        .where((task) => task.dueDate != null && isSameDate(task.dueDate!, now))
        .toList();
  }

  List<Task> tasksWithDueDate() {
    return sortedTasks().where((task) => task.dueDate != null).toList();
  }

  Map<String, List<Task>> tasksByProject() {
    final result = <String, List<Task>>{};
    for (final task in sortedTasks()) {
      final name = (task.project == null || task.project!.trim().isEmpty)
          ? 'No Project'
          : task.project!.trim();
      result.putIfAbsent(name, () => []).add(task);
    }
    return result;
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;
    _isDarkMode = enabled;
    notifyListeners();
    await _preferences.setBool(_darkModeKey, enabled);
  }

  Future<void> addTask(Task task) async {
    _tasks = [..._tasks, task];
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    _tasks = _tasks
        .map((task) => task.id == updatedTask.id ? updatedTask : task)
        .toList();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> deleteTask(String id) async {
    _tasks = _tasks.where((task) => task.id != id).toList();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleTaskCompleted(String id) async {
    _tasks = _tasks.map((task) {
      if (task.id != id) return task;
      return task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
    }).toList();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleSubtaskCompleted(String taskId, String subtaskId) async {
    _tasks = _tasks.map((task) {
      if (task.id != taskId) return task;
      final updatedSubtasks = task.subtasks.map((subtask) {
        if (subtask.id != subtaskId) return subtask;
        return subtask.copyWith(isCompleted: !subtask.isCompleted);
      }).toList();
      return task.copyWith(
        subtasks: updatedSubtasks,
        updatedAt: DateTime.now(),
      );
    }).toList();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> _saveTasks() async {
    final encoded = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await _preferences.setString(_tasksKey, encoded);
  }
}
