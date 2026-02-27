import 'package:flutter/cupertino.dart';

import '../utils/app_utils.dart';

class TodoList {
  const TodoList({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.colorKey,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  IconData get icon => iconForKey(iconKey);

  TodoList copyWith({
    String? name,
    String? description,
    String? iconKey,
    String? colorKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoList(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconKey': iconKey,
      'colorKey': colorKey,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id']?.toString() ?? generateId(),
      name: json['name']?.toString() ?? 'Untitled',
      description: json['description']?.toString() ?? '',
      iconKey: json['iconKey']?.toString() ?? 'person_fill',
      colorKey: json['colorKey']?.toString() ?? 'blue',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
