import '../utils/app_utils.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.subtasks,
    required this.tags,
    required this.project,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final List<Subtask> subtasks;
  final List<String> tags;
  final String? project;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get completedSubtaskCount =>
      subtasks.where((subtask) => subtask.isCompleted).length;

  Task copyWith({
    String? title,
    String? description,
    Object? dueDate = _taskUnset,
    List<Subtask>? subtasks,
    List<String>? tags,
    Object? project = _taskUnset,
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
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      project: identical(project, _taskUnset)
          ? this.project
          : project as String?,
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
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'tags': tags,
      'project': project,
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

    return Task(
      id: json['id']?.toString() ?? generateId(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'].toString()),
      subtasks: rawSubtasks.map(Subtask.fromJson).toList(),
      tags: rawTags,
      project: json['project']?.toString(),
      isCompleted: json['isCompleted'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
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
