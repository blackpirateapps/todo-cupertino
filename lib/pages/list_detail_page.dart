import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../models/todo_list.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/task_card.dart';
import 'task_editor_page.dart';

class ListDetailPage extends StatelessWidget {
  const ListDetailPage({super.key, required this.state, required this.list});

  final AppState state;
  final TodoList list;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(list.name),
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
            final tasks = state.tasksForList(list.id);
            if (tasks.isEmpty) {
              return const EmptyState(
                title: 'No tasks in this list',
                subtitle: 'Create a task to get started.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  listName: list.name,
                  onTap: () => _openTaskEditor(context, task: task),
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

  Future<void> _openTaskEditor(BuildContext context, {Task? task}) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => TaskEditorPage(
          state: state,
          initialTask: task,
          initialListId: list.id,
        ),
      ),
    );
  }
}
