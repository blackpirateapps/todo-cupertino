import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../models/todo_list.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({
    super.key,
    required this.state,
    this.initialTask,
    this.initialListId,
  });

  final AppState state;
  final Task? initialTask;
  final String? initialListId;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late bool _isCompleted;
  late TaskRepeat _repeat;
  late TaskPriority _priority;
  DateTime? _dueDate;
  late String _listId;

  final List<TextEditingController> _subtaskControllers = [];
  final List<bool> _subtaskCompleted = [];
  final List<String> _subtaskIds = [];

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    final fallbackListId = widget.initialListId ?? widget.state.lists.first.id;
    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.description ?? '');
    _isCompleted = task?.isCompleted ?? false;
    _repeat = task?.repeat ?? TaskRepeat.none;
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _listId = task?.listId ?? fallbackListId;

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
    _notesController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.state.listById(_listId);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        middle: Text(_isEditing ? 'Edit Task' : 'New Task'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTask,
          child: const Text('Done'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
          children: [
            CupertinoTextField(
              controller: _titleController,
              placeholder: 'Write project report',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w300),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.transparent,
              ),
            ),
            const SizedBox(height: 6),
            _Panel(
              child: Column(
                children: [
                  _SettingRow(
                    icon: CupertinoIcons.calendar,
                    label: 'Date:',
                    value: _dueDate == null
                        ? 'No date'
                        : formatDateTime(_dueDate!),
                    onTap: _pickDueDate,
                  ),
                  _line(context),
                  _SettingRow(
                    icon: CupertinoIcons.repeat,
                    label: 'Repeat:',
                    value: _repeat.label,
                    onTap: _pickRepeat,
                  ),
                  _line(context),
                  _SettingRow(
                    icon: CupertinoIcons.list_bullet,
                    label: 'List:',
                    value: list?.name ?? 'Unknown',
                    onTap: _pickList,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Panel(
              child: Row(
                children: [
                  const Icon(CupertinoIcons.tag, size: 18),
                  const SizedBox(width: 10),
                  const Text('Priority:'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoSlidingSegmentedControl<TaskPriority>(
                      groupValue: _priority,
                      children: const {
                        TaskPriority.low: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Low'),
                        ),
                        TaskPriority.medium: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Medium'),
                        ),
                        TaskPriority.high: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('High'),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value == null) return;
                        setState(() => _priority = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Subtasks',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _Panel(
              child: Column(
                children: [
                  if (_subtaskControllers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No subtasks yet',
                        style: TextStyle(color: CupertinoColors.secondaryLabel),
                      ),
                    ),
                  for (var i = 0; i < _subtaskControllers.length; i++) ...[
                    _SubtaskRow(
                      controller: _subtaskControllers[i],
                      completed: _subtaskCompleted[i],
                      onToggle: () => setState(
                        () => _subtaskCompleted[i] = !_subtaskCompleted[i],
                      ),
                      onRemove: () => _removeSubtask(i),
                    ),
                    if (i != _subtaskControllers.length - 1) _line(context),
                  ],
                  if (_subtaskControllers.isNotEmpty) _line(context),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.centerLeft,
                    onPressed: _addSubtask,
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.add, size: 20),
                        SizedBox(width: 6),
                        Text('Add Subtask'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Panel(
              child: CupertinoTextField(
                controller: _notesController,
                placeholder: 'Notes and details...',
                minLines: 3,
                maxLines: 6,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: CupertinoColors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text('Completed', style: TextStyle(fontSize: 16)),
                ),
                CupertinoSwitch(
                  value: _isCompleted,
                  onChanged: (value) => setState(() => _isCompleted = value),
                ),
              ],
            ),
            if (_isEditing)
              CupertinoButton(
                onPressed: _confirmDelete,
                child: const Text(
                  'Delete Task',
                  style: TextStyle(color: CupertinoColors.systemRed),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context) {
    return Container(
      height: 0.5,
      color: CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
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
    final initial = _dueDate ?? DateTime(now.year, now.month, now.day, 10);
    var selected = initial;

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(selected),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initial,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickList() async {
    final result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Choose List'),
          actions: [
            for (final list in widget.state.lists)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(list.id),
                child: Text(list.name),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _listId = result);
    }
  }

  Future<void> _pickRepeat() async {
    final result = await showCupertinoModalPopup<TaskRepeat>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Repeat'),
          actions: [
            for (final repeat in TaskRepeat.values)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(repeat),
                child: Text(repeat.label),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _repeat = result);
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

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

    final existing = widget.initialTask;
    final task = Task(
      id: existing?.id ?? generateId(),
      title: title,
      description: _notesController.text.trim(),
      dueDate: _dueDate,
      repeat: _repeat,
      listId: _listId,
      priority: _priority,
      subtasks: subtasks,
      tags: const [],
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
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

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 8),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: CupertinoColors.label.resolveFrom(context),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(CupertinoIcons.chevron_forward, size: 14),
        ],
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.controller,
    required this.completed,
    required this.onToggle,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(24),
          onPressed: onToggle,
          child: Icon(
            completed
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.circle,
          ),
        ),
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Subtask',
            decoration: const BoxDecoration(color: CupertinoColors.transparent),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(24),
          onPressed: onRemove,
          child: const Icon(
            CupertinoIcons.minus_circle,
            color: CupertinoColors.systemRed,
            size: 18,
          ),
        ),
      ],
    );
  }
}
