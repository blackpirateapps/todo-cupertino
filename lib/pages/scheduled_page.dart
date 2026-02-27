import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/task_card.dart';
import 'task_editor_page.dart';

class ScheduledPage extends StatelessWidget {
  const ScheduledPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Scheduled')),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final tasks = state.tasksWithDueDate();
            if (tasks.isEmpty) {
              return const EmptyState(
                title: 'No scheduled tasks',
                subtitle: 'Tasks with due dates will appear here.',
                icon: CupertinoIcons.calendar,
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
