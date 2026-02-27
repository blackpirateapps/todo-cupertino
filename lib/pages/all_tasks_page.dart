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
                    _TasksFilter.scheduled: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      child: Text('Scheduled'),
                    ),
                    _TasksFilter.flagged: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      child: Text('Flagged'),
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
                            onTap: () =>
                                _openTaskEditor(context, task: tasks[i]),
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
      case _TasksFilter.scheduled:
        tasks = tasks.where((t) => t.dueDate != null);
        break;
      case _TasksFilter.flagged:
        tasks = tasks.where((t) => t.priority == TaskPriority.high);
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
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.listName,
    required this.onToggle,
    required this.onTap,
    required this.onStartFocus,
  });

  final Task task;
  final String listName;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
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
          const SizedBox(width: 6),
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

enum _TasksFilter { all, today, scheduled, flagged }
