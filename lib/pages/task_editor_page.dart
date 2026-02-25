import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({super.key, required this.state, this.initialTask});

  final AppState state;
  final Task? initialTask;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _projectController;
  late final TextEditingController _tagsController;
  late bool _isCompleted;
  DateTime? _dueDate;

  final List<TextEditingController> _subtaskControllers = [];
  final List<bool> _subtaskCompleted = [];
  final List<String> _subtaskIds = [];

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _projectController = TextEditingController(text: task?.project ?? '');
    _tagsController = TextEditingController(
      text: (task?.tags ?? []).join(', '),
    );
    _isCompleted = task?.isCompleted ?? false;
    _dueDate = task?.dueDate;

    final subtasks = task?.subtasks ?? <Subtask>[];
    for (final subtask in subtasks) {
      _subtaskControllers.add(TextEditingController(text: subtask.title));
      _subtaskCompleted.add(subtask.isCompleted);
      _subtaskIds.add(subtask.id);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectController.dispose();
    _tagsController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Task' : 'New Task';
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Title'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'Task title',
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Description'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _descriptionController,
                    placeholder: 'Details',
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Project'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _projectController,
                    placeholder: 'e.g. Personal, Work',
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Tags'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _tagsController,
                    placeholder: 'Comma-separated tags',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Due Date'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'No due date'
                              : formatDateTime(_dueDate!),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        onPressed: _pickDueDate,
                        child: const Text('Pick'),
                      ),
                      if (_dueDate != null)
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          onPressed: () => setState(() => _dueDate = null),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Completed',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      CupertinoSwitch(
                        value: _isCompleted,
                        onChanged: (value) =>
                            setState(() => _isCompleted = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Subtasks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _addSubtask,
                        child: const Icon(CupertinoIcons.add_circled),
                      ),
                    ],
                  ),
                  if (_subtaskControllers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'No subtasks yet.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  for (var i = 0; i < _subtaskControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CupertinoSwitch(
                            value: _subtaskCompleted[i],
                            onChanged: (value) {
                              setState(() {
                                _subtaskCompleted[i] = value;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CupertinoTextField(
                              controller: _subtaskControllers[i],
                              placeholder: 'Subtask',
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 6),
                            onPressed: () => _removeSubtask(i),
                            child: const Icon(
                              CupertinoIcons.minus_circle,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              SectionCard(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _confirmDelete,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.systemRed,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete Task',
                        style: TextStyle(color: CupertinoColors.systemRed),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addSubtask() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
      _subtaskCompleted.add(false);
      _subtaskIds.add(generateId());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
      _subtaskCompleted.removeAt(index);
      _subtaskIds.removeAt(index);
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? DateTime(now.year, now.month, now.day, 9);
    var selected = initial;

    final picked = await showCupertinoModalPopup<DateTime?>(
      context: context,
      builder: (context) {
        final bg = CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground,
          context,
        );
        return Container(
          height: 320,
          color: bg,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.separator,
                        context,
                      ),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(selected),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initial,
                  use24hFormat: false,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Title required'),
          content: const Text('Please enter a title for the task.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final subtasks = <Subtask>[];
    for (var i = 0; i < _subtaskControllers.length; i++) {
      final text = _subtaskControllers[i].text.trim();
      if (text.isEmpty) continue;
      subtasks.add(
        Subtask(
          id: _subtaskIds[i],
          title: text,
          isCompleted: _subtaskCompleted[i],
        ),
      );
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final existing = widget.initialTask;
    final task = Task(
      id: existing?.id ?? generateId(),
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      subtasks: subtasks,
      tags: tags,
      project: _projectController.text.trim().isEmpty
          ? null
          : _projectController.text.trim(),
      isCompleted: _isCompleted,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (existing == null) {
      await widget.state.addTask(task);
    } else {
      await widget.state.updateTask(task);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final task = widget.initialTask;
    if (task == null) return;

    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently delete "${task.title}".'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await widget.state.deleteTask(task.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
}
