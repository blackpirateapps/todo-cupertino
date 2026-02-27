import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import 'task_editor_page.dart';

class TodaySearchPage extends StatefulWidget {
  const TodaySearchPage({
    super.key,
    required this.state,
    required this.onStartFocus,
  });

  final AppState state;
  final void Function(Task task) onStartFocus;

  @override
  State<TodaySearchPage> createState() => _TodaySearchPageState();
}

class _TodaySearchPageState extends State<TodaySearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Search Today')),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) {
            final tasks = _filteredTasks();
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children: [
                CupertinoSearchTextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value.trim()),
                ),
                const SizedBox(height: 10),
                if (tasks.isEmpty)
                  const EmptyState(
                    title: 'No matching tasks today',
                    subtitle: 'Try another search term.',
                  )
                else
                  SectionCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < tasks.length; i++) ...[
                          _TodaySearchRow(
                            task: tasks[i],
                            listName: widget.state.listNameForTask(tasks[i]),
                            onTap: () => _openTaskEditor(tasks[i]),
                            onToggle: () =>
                                widget.state.toggleTaskCompleted(tasks[i].id),
                            onStartFocus: () => widget.onStartFocus(tasks[i]),
                          ),
                          if (i != tasks.length - 1)
                            Container(
                              margin: const EdgeInsets.only(left: 42),
                              height: 0.5,
                              color: CupertinoColors.separator.resolveFrom(
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

  List<Task> _filteredTasks() {
    final query = _query.toLowerCase();
    return widget.state.tasksDueToday().where((task) {
      if (query.isEmpty) return true;
      final listName = widget.state.listNameForTask(task).toLowerCase();
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          listName.contains(query);
    }).toList();
  }

  Future<void> _openTaskEditor(Task task) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) =>
            TaskEditorPage(state: widget.state, initialTask: task),
      ),
    );
  }
}

class _TodaySearchRow extends StatelessWidget {
  const _TodaySearchRow({
    required this.task,
    required this.listName,
    required this.onTap,
    required this.onToggle,
    required this.onStartFocus,
  });

  final Task task;
  final String listName;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      onPressed: onTap,
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(24),
            onPressed: onToggle,
            child: Icon(
              task.isCompleted
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: task.isCompleted
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  listName,
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(24),
            onPressed: onStartFocus,
            child: const Icon(
              CupertinoIcons.play_circle_fill,
              color: CupertinoColors.activeBlue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
