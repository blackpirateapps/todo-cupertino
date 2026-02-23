import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.load();
  runApp(TodoCupertinoApp(state: appState));
}

class TodoCupertinoApp extends StatelessWidget {
  const TodoCupertinoApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
            primaryColor: CupertinoColors.activeBlue,
          ),
          home: AppShell(state: state),
        );
      },
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_alt),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => HomePage(state: state),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => TodayPage(state: state),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => ProjectsPage(state: state),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => SettingsPage(state: state),
            );
          default:
            return CupertinoTabView(
              builder: (context) => HomePage(state: state),
            );
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Todo Cupertino'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openTaskEditor(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final tasks = state.sortedTasks();
            if (tasks.isEmpty) {
              return const _EmptyState(
                title: 'No tasks yet',
                subtitle: 'Tap + to create your first task.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskCard(
                task: tasks[index],
                onTap: () => _openTaskEditor(context, task: tasks[index]),
                onToggleComplete: () => state.toggleTaskCompleted(tasks[index].id),
                onToggleSubtask: (subtaskId) =>
                    state.toggleSubtaskCompleted(tasks[index].id, subtaskId),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openTaskEditor(BuildContext context, {Task? task}) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => TaskEditorPage(state: state, initialTask: task),
      ),
    );
  }
}

class TodayPage extends StatelessWidget {
  const TodayPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Today'),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final todayTasks = state.tasksDueToday();
            if (todayTasks.isEmpty) {
              return const _EmptyState(
                title: 'Nothing due today',
                subtitle: 'Tasks with a due date of today will appear here.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: todayTasks.length,
              itemBuilder: (context, index) => TaskCard(
                task: todayTasks[index],
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (context) =>
                        TaskEditorPage(state: state, initialTask: todayTasks[index]),
                  ),
                ),
                onToggleComplete: () =>
                    state.toggleTaskCompleted(todayTasks[index].id),
                onToggleSubtask: (subtaskId) => state.toggleSubtaskCompleted(
                  todayTasks[index].id,
                  subtaskId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Projects'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (context) => TaskEditorPage(state: state),
            ),
          ),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final groups = state.tasksByProject();
            if (groups.isEmpty) {
              return const _EmptyState(
                title: 'No projects yet',
                subtitle: 'Assign a project to a task to organize them here.',
              );
            }
            final projectNames = groups.keys.toList()..sort();
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                for (final projectName in projectNames) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...groups[projectName]!.map(
                    (task) => TaskCard(
                      task: task,
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (context) =>
                              TaskEditorPage(state: state, initialTask: task),
                        ),
                      ),
                      onToggleComplete: () => state.toggleTaskCompleted(task.id),
                      onToggleSubtask: (subtaskId) =>
                          state.toggleSubtaskCompleted(task.id, subtaskId),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _SectionCard(
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.moon_fill, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CupertinoSwitch(
                        value: state.isDarkMode,
                        onChanged: state.setDarkMode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All tasks and settings are stored locally on the device using SharedPreferences.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _projectController = TextEditingController(text: task?.project ?? '');
    _tagsController = TextEditingController(text: (task?.tags ?? []).join(', '));
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
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Title'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'Task title',
                  ),
                  const SizedBox(height: 12),
                  const _FieldLabel('Description'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _descriptionController,
                    placeholder: 'Details',
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  const _FieldLabel('Project'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _projectController,
                    placeholder: 'e.g. Personal, Work',
                  ),
                  const SizedBox(height: 12),
                  const _FieldLabel('Tags'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _tagsController,
                    placeholder: 'Comma-separated tags',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Due Date'),
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
                        onChanged: (value) => setState(() => _isCompleted = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
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
              _SectionCard(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onToggleSubtask,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final void Function(String subtaskId) onToggleSubtask;

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoDynamicColor.resolve(
      CupertinoColors.secondarySystemGroupedBackground,
      context,
    );
    final separator = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        !task.isCompleted &&
        task.dueDate!.isBefore(now) &&
        !isSameDate(task.dueDate!, now);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: separator.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(12),
            onPressed: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onToggleComplete,
                  child: Icon(
                    task.isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                    color: task.isCompleted
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.inactiveGray,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (task.project != null && task.project!.isNotEmpty)
                            _Pill(
                              text: task.project!,
                              icon: CupertinoIcons.folder_solid,
                            ),
                          if (task.dueDate != null)
                            _Pill(
                              text: formatDateTime(task.dueDate!),
                              icon: CupertinoIcons.calendar,
                              color: isOverdue
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.activeBlue,
                            ),
                          if (task.subtasks.isNotEmpty)
                            _Pill(
                              text:
                                  '${task.completedSubtaskCount}/${task.subtasks.length} subtasks',
                              icon: CupertinoIcons.check_mark_circled,
                            ),
                          for (final tag in task.tags.take(4))
                            _Pill(
                              text: '#$tag',
                              icon: CupertinoIcons.tag_solid,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
          ),
          if (task.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  Container(
                    height: 0.5,
                    color: separator.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  for (final subtask in task.subtasks)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(24),
                            onPressed: () => onToggleSubtask(subtask.id),
                            child: Icon(
                              subtask.isCompleted
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.circle,
                              size: 18,
                              color: subtask.isCompleted
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.inactiveGray,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtask.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.secondaryLabel,
                                decoration: subtask.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.icon,
    this.color,
  });

  final String text;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ?? CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context);
    final bg = resolvedColor.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: resolvedColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: resolvedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoDynamicColor.resolve(
      CupertinoColors.secondarySystemGroupedBackground,
      context,
    );
    final separator = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: separator.withValues(alpha: 0.3), width: 0.5),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled,
              size: 44,
              color: CupertinoColors.inactiveGray,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  AppState._({
    required SharedPreferences preferences,
    required List<Task> tasks,
    required bool isDarkMode,
  })  : _preferences = preferences,
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
      dueDate: identical(dueDate, _taskUnset) ? this.dueDate : dueDate as DateTime?,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      project: identical(project, _taskUnset) ? this.project : project as String?,
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
    final rawSubtasks = (json['subtasks'] as List<dynamic>? ?? const <dynamic>[])
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
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
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

  Subtask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
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
final Random _random = Random();

String generateId() {
  final t = DateTime.now().microsecondsSinceEpoch;
  final r = _random.nextInt(1 << 32);
  return '$t-$r';
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDateTime(DateTime value) {
  final monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = monthNames[value.month - 1];
  final day = value.day.toString();
  final year = value.year;

  var hour = value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '$month $day, $year  $hour:$minute $suffix';
}
