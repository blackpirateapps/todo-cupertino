import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/task_card.dart';
import 'task_editor_page.dart';

class FlaggedPage extends StatelessWidget {
  const FlaggedPage({
    super.key,
    required this.state,
    required this.onStartFocus,
  });

  final AppState state;
  final void Function(Task task) onStartFocus;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Flagged')),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final tasks = state
                .sortedTasks()
                .where((task) => task.priority == TaskPriority.high)
                .toList();

            if (tasks.isEmpty) {
              return const EmptyState(
                title: 'No high-priority tasks',
                subtitle: 'Set priority to High to see tasks here.',
                icon: CupertinoIcons.flag,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  listName: state.listNameForTask(task),
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (context) =>
                          TaskEditorPage(state: state, initialTask: task),
                    ),
                  ),
                  onToggleComplete: () => state.toggleTaskCompleted(task.id),
                  onToggleSubtask: (subtaskId) =>
                      state.toggleSubtaskCompleted(task.id, subtaskId),
                  onStartFocus: () => onStartFocus(task),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
