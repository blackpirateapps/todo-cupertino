import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/task_card.dart';
import 'task_editor_page.dart';

class AllTasksPage extends StatelessWidget {
  const AllTasksPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('All Tasks'),
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
              return const EmptyState(
                title: 'No tasks yet',
                subtitle: 'Tap + to create your first task.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: tasks.length,
              itemBuilder: (context, index) =>
                  _TaskCardWrapper(state: state, task: tasks[index]),
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

class _TaskCardWrapper extends StatelessWidget {
  const _TaskCardWrapper({required this.state, required this.task});

  final AppState state;
  final Task task;

  @override
  Widget build(BuildContext context) {
    return TaskCard(
      task: task,
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (context) => TaskEditorPage(state: state, initialTask: task),
        ),
      ),
      onToggleComplete: () => state.toggleTaskCompleted(task.id),
      onToggleSubtask: (subtaskId) =>
          state.toggleSubtaskCompleted(task.id, subtaskId),
    );
  }
}
