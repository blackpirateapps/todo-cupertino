import '../utils/app_utils.dart';

enum TaskPriority { low, medium, high }

enum TaskRepeat { none, daily, weekly, monthly }

extension TaskPriorityLabel on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  int get sortWeight {
    switch (this) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }
}

extension TaskRepeatLabel on TaskRepeat {
  String get label {
    switch (this) {
      case TaskRepeat.none:
        return 'Never';
      case TaskRepeat.daily:
        return 'Daily';
      case TaskRepeat.weekly:
        return 'Weekly';
      case TaskRepeat.monthly:
        return 'Monthly';
    }
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.repeat,
    required this.listId,
    required this.priority,
    required this.subtasks,
    required this.tags,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskRepeat repeat;
  final String listId;
  final TaskPriority priority;
  final List<Subtask> subtasks;
  final List<String> tags;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get completedSubtaskCount =>
      subtasks.where((subtask) => subtask.isCompleted).length;

  Task copyWith({
    String? title,
    String? description,
    Object? dueDate = _taskUnset,
    TaskRepeat? repeat,
    String? listId,
    TaskPriority? priority,
    List<Subtask>? subtasks,
    List<String>? tags,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: identical(dueDate, _taskUnset)
          ? this.dueDate
          : dueDate as DateTime?,
      repeat: repeat ?? this.repeat,
      listId: listId ?? this.listId,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'repeat': repeat.name,
      'listId': listId,
      'priority': priority.name,
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'tags': tags,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawSubtasks =
        (json['subtasks'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();
    final rawTags = (json['tags'] as List<dynamic>? ?? const <dynamic>[])
        .map((tag) => tag.toString())
        .toList();

    final rawListId = json['listId']?.toString();
    final legacyProject = json['project']?.toString();

    return Task(
      id: json['id']?.toString() ?? generateId(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'].toString()),
      repeat: _parseRepeat(json['repeat']?.toString()),
      listId: _normalizeListId(rawListId, legacyProject),
      priority: _parsePriority(json['priority']?.toString()),
      subtasks: rawSubtasks.map(Subtask.fromJson).toList(),
      tags: rawTags,
      isCompleted: json['isCompleted'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static String _normalizeListId(String? listId, String? legacyProject) {
    if (listId != null && listId.trim().isNotEmpty) {
      return listId.trim();
    }
    final project = legacyProject?.trim();
    if (project != null && project.isNotEmpty) {
      return '__legacy_project__$project';
    }
    return '';
  }

  static TaskPriority _parsePriority(String? raw) {
    for (final item in TaskPriority.values) {
      if (item.name == raw) return item;
    }
    return TaskPriority.medium;
  }

  static TaskRepeat _parseRepeat(String? raw) {
    for (final item in TaskRepeat.values) {
      if (item.name == raw) return item;
    }
    return TaskRepeat.none;
  }
}

class Subtask {
  const Subtask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  Subtask copyWith({String? title, bool? isCompleted}) {
    return Subtask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id']?.toString() ?? generateId(),
      title: json['title']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
    );
  }
}

const _taskUnset = Object();
