import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';
import 'task_editor_page.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({
    super.key,
    required this.state,
    required this.onStartFocus,
  });

  final AppState state;
  final void Function(Task task) onStartFocus;

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  String _searchText = '';
  _TasksFilter _filter = _TasksFilter.all;
  final Set<String> _expandedTaskIds = <String>{};

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(CupertinoIcons.back), Text('Back')],
          ),
        ),
        middle: const Text('Tasks'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openTaskEditor(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) {
            final tasks = _filteredTasks(widget.state);
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children: [
                CupertinoSlidingSegmentedControl<_TasksFilter>(
                  groupValue: _filter,
                  children: const {
                    _TasksFilter.all: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      child: Text('All'),
                    ),
                    _TasksFilter.today: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      child: Text('Today'),
                    ),
                  },
                  onValueChanged: (value) {
                    if (value == null) return;
                    setState(() => _filter = value);
                  },
                ),
                const SizedBox(height: 10),
                CupertinoSearchTextField(
                  onChanged: (value) =>
                      setState(() => _searchText = value.trim()),
                ),
                const SizedBox(height: 10),
                if (tasks.isEmpty)
                  const EmptyState(
                    title: 'No matching tasks',
                    subtitle: 'Try changing filter or search.',
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.secondarySystemGroupedBackground
                          .resolveFrom(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < tasks.length; i++) ...[
                          _TaskRow(
                            task: tasks[i],
                            listName: widget.state.listNameForTask(tasks[i]),
                            onToggle: () =>
                                widget.state.toggleTaskCompleted(tasks[i].id),
                            onTap: () => _toggleExpanded(tasks[i].id),
                            isExpanded: _expandedTaskIds.contains(tasks[i].id),
                            onEdit: () =>
                                _openTaskEditor(context, task: tasks[i]),
                            onToggleSubtask: (subtaskId) => widget.state
                                .toggleSubtaskCompleted(tasks[i].id, subtaskId),
                            onStartFocus: () => widget.onStartFocus(tasks[i]),
                          ),
                          if (i != tasks.length - 1)
                            Container(
                              margin: const EdgeInsets.only(left: 42),
                              height: 0.5,
                              color: CupertinoDynamicColor.resolve(
                                CupertinoColors.separator,
                                context,
                              ),
                            ),
                        ],
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

  List<Task> _filteredTasks(AppState state) {
    Iterable<Task> tasks = state.sortedTasks();
    final now = DateTime.now();

    switch (_filter) {
      case _TasksFilter.all:
        break;
      case _TasksFilter.today:
        tasks = tasks.where(
          (t) => t.dueDate != null && isSameDate(t.dueDate!, now),
        );
        break;
    }

    if (_searchText.isNotEmpty) {
      final query = _searchText.toLowerCase();
      tasks = tasks.where(
        (t) =>
            t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query),
      );
    }

    return tasks.toList();
  }

  Future<void> _openTaskEditor(BuildContext context, {Task? task}) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) =>
            TaskEditorPage(state: widget.state, initialTask: task),
      ),
    );
  }

  void _toggleExpanded(String taskId) {
    setState(() {
      if (_expandedTaskIds.contains(taskId)) {
        _expandedTaskIds.remove(taskId);
      } else {
        _expandedTaskIds.add(taskId);
      }
    });
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.listName,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
    required this.onToggleSubtask,
    required this.isExpanded,
    required this.onStartFocus,
  });

  final Task task;
  final String listName;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final void Function(String subtaskId) onToggleSubtask;
  final bool isExpanded;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          onPressed: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(26),
                onPressed: onToggle,
                child: Icon(
                  task.isCompleted
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.circle,
                  color: task.isCompleted
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.inactiveGray,
                  size: 26,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted
                            ? CupertinoColors.secondaryLabel
                            : CupertinoColors.label,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(task, listName),
                      style: const TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 14,
                      ),
                    ),
                    if (task.focusAccumulatedMinutes > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${task.focusAccumulatedMinutes}m focus',
                          style: const TextStyle(
                            color: CupertinoColors.systemPurple,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (!task.isCompleted)
                Icon(
                  CupertinoIcons.flag_fill,
                  color: task.priority == TaskPriority.high
                      ? CupertinoColors.systemRed
                      : task.priority == TaskPriority.medium
                      ? CupertinoColors.systemYellow
                      : CupertinoColors.systemGrey,
                  size: 20,
                ),
              const SizedBox(width: 4),
              Icon(
                isExpanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 16,
                color: CupertinoColors.tertiaryLabel,
              ),
              const SizedBox(width: 4),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(24),
                onPressed: onStartFocus,
                child: const Icon(
                  CupertinoIcons.play_circle_fill,
                  color: CupertinoColors.activeBlue,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          _ExpandedTaskDetails(
            task: task,
            onEdit: onEdit,
            onToggleSubtask: onToggleSubtask,
          ),
      ],
    );
  }

  String _subtitle(Task task, String listName) {
    if (task.isCompleted) {
      return 'Completed • $listName';
    }
    if (task.dueDate == null) {
      return listName;
    }
    return '${_dateLabel(task.dueDate!)} • $listName';
  }

  String _dateLabel(DateTime value) {
    final now = DateTime.now();
    if (isSameDate(value, now)) {
      return 'Today, ${formatTimeOnly(value)}';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (isSameDate(value, tomorrow)) {
      return 'Tomorrow, ${formatTimeOnly(value)}';
    }
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[value.weekday - 1]}, ${formatTimeOnly(value)}';
  }
}

class _ExpandedTaskDetails extends StatelessWidget {
  const _ExpandedTaskDetails({
    required this.task,
    required this.onEdit,
    required this.onToggleSubtask,
  });

  final Task task;
  final VoidCallback onEdit;
  final void Function(String subtaskId) onToggleSubtask;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(42, 0, 10, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.description.trim().isNotEmpty)
            Text(
              task.description.trim(),
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 13,
              ),
            ),
          if (task.description.trim().isNotEmpty) const SizedBox(height: 6),
          Text(
            'Priority: ${task.priority.label} • Repeat: ${task.repeat.label}',
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 12,
            ),
          ),
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Subtasks',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            for (final subtask in task.subtasks)
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.square(22),
                    onPressed: () => onToggleSubtask(subtask.id),
                    child: Icon(
                      subtask.isCompleted
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      size: 17,
                      color: subtask.isCompleted
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.inactiveGray,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtask.title,
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 12,
                        decoration: subtask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onEdit,
            child: const Text('Edit Task'),
          ),
        ],
      ),
    );
  }
}

enum _TasksFilter { all, today }
