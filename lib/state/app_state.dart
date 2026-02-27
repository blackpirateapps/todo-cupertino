import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/todo_list.dart';
import '../utils/app_utils.dart';

class AppState extends ChangeNotifier {
  AppState._({
    required SharedPreferences preferences,
    required List<Task> tasks,
    required List<TodoList> lists,
    required bool isDarkMode,
  }) : _preferences = preferences,
       _tasks = tasks,
       _lists = lists,
       _isDarkMode = isDarkMode;

  static const _tasksKey = 'tasks_v2';
  static const _legacyTasksKey = 'tasks_v1';
  static const _listsKey = 'lists_v1';
  static const _darkModeKey = 'dark_mode_v1';

  final SharedPreferences _preferences;
  List<Task> _tasks;
  List<TodoList> _lists;
  bool _isDarkMode;

  static Future<AppState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final parsedLists = _decodeLists(preferences.getString(_listsKey));
    final lists = parsedLists.isEmpty ? _defaultLists() : parsedLists;

    final rawTasks =
        preferences.getString(_tasksKey) ??
        preferences.getString(_legacyTasksKey);
    final parsedTasks = _decodeTasks(rawTasks);

    var didMigrate = parsedLists.isEmpty;
    final migratedTasks = <Task>[];
    final mutableLists = [...lists];

    String ensureListByName(String name, {String? iconKey}) {
      final normalized = name.trim().toLowerCase();
      for (final list in mutableLists) {
        if (list.name.trim().toLowerCase() == normalized) return list.id;
      }
      final now = DateTime.now();
      final created = TodoList(
        id: generateId(),
        name: name.trim(),
        description: '',
        iconKey: iconKey ?? 'folder_fill',
        createdAt: now,
        updatedAt: now,
      );
      mutableLists.add(created);
      didMigrate = true;
      return created.id;
    }

    for (final task in parsedTasks) {
      var listId = task.listId;
      if (listId.startsWith('__legacy_project__')) {
        final legacyName = listId.replaceFirst('__legacy_project__', '');
        listId = ensureListByName(legacyName);
        didMigrate = true;
      }
      final exists = mutableLists.any((list) => list.id == listId);
      if (!exists) {
        listId = mutableLists.first.id;
        didMigrate = true;
      }
      migratedTasks.add(
        listId == task.listId ? task : task.copyWith(listId: listId),
      );
    }

    final state = AppState._(
      preferences: preferences,
      tasks: migratedTasks,
      lists: mutableLists,
      isDarkMode: preferences.getBool(_darkModeKey) ?? false,
    );

    if (didMigrate) {
      await state._saveLists();
      await state._saveTasks();
      await preferences.remove(_legacyTasksKey);
    }

    return state;
  }

  bool get isDarkMode => _isDarkMode;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<TodoList> get lists => List.unmodifiable(_lists);

  TodoList? listById(String id) {
    for (final list in _lists) {
      if (list.id == id) return list;
    }
    return null;
  }

  String listNameForTask(Task task) {
    return listById(task.listId)?.name ?? 'Unknown List';
  }

  List<Task> sortedTasks([Iterable<Task>? source]) {
    final copy = [...(source ?? _tasks)];
    copy.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final priorityOrder = b.priority.sortWeight.compareTo(
        a.priority.sortWeight,
      );
      if (priorityOrder != 0) return priorityOrder;
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
    return sortedTasks(
      _tasks.where(
        (task) => task.dueDate != null && isSameDate(task.dueDate!, now),
      ),
    );
  }

  List<Task> homeTodayTasks() {
    final dueToday = tasksDueToday();
    if (dueToday.length <= 3) return dueToday;

    final highPriority = dueToday.where(
      (task) => task.priority == TaskPriority.high,
    );
    final sortedHigh = sortedTasks(highPriority);
    if (sortedHigh.isNotEmpty) {
      return sortedHigh;
    }
    return dueToday.take(3).toList();
  }

  List<Task> tasksWithDueDate() {
    return sortedTasks(_tasks.where((task) => task.dueDate != null));
  }

  List<Task> tasksForList(String listId) {
    return sortedTasks(_tasks.where((task) => task.listId == listId));
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;
    _isDarkMode = enabled;
    notifyListeners();
    await _preferences.setBool(_darkModeKey, enabled);
  }

  Future<void> addList(TodoList list) async {
    _lists = [..._lists, list];
    notifyListeners();
    await _saveLists();
  }

  Future<void> updateList(TodoList updatedList) async {
    _lists = _lists
        .map((list) => list.id == updatedList.id ? updatedList : list)
        .toList();
    notifyListeners();
    await _saveLists();
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

  Future<void> _saveLists() async {
    final encoded = jsonEncode(_lists.map((list) => list.toJson()).toList());
    await _preferences.setString(_listsKey, encoded);
  }

  static List<Task> _decodeTasks(String? rawTasks) {
    final parsed = <Task>[];
    if (rawTasks == null || rawTasks.isEmpty) return parsed;
    try {
      final list = jsonDecode(rawTasks) as List<dynamic>;
      for (final item in list) {
        parsed.add(Task.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {
      // Ignore invalid persisted data and start fresh.
    }
    return parsed;
  }

  static List<TodoList> _decodeLists(String? rawLists) {
    final parsed = <TodoList>[];
    if (rawLists == null || rawLists.isEmpty) return parsed;
    try {
      final list = jsonDecode(rawLists) as List<dynamic>;
      for (final item in list) {
        parsed.add(TodoList.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {
      // Ignore invalid persisted data and start fresh.
    }
    return parsed;
  }

  static List<TodoList> _defaultLists() {
    final now = DateTime.now();
    return [
      TodoList(
        id: generateId(),
        name: 'Personal',
        description: 'Personal tasks',
        iconKey: 'person_fill',
        createdAt: now,
        updatedAt: now,
      ),
      TodoList(
        id: generateId(),
        name: 'Work',
        description: 'Work tasks',
        iconKey: 'briefcase_fill',
        createdAt: now,
        updatedAt: now,
      ),
      TodoList(
        id: generateId(),
        name: 'Groceries',
        description: 'Shopping and household',
        iconKey: 'cart_fill',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
