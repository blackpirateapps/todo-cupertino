import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';

class FocusTaskPickerPage extends StatefulWidget {
  const FocusTaskPickerPage({super.key, required this.state});

  final AppState state;

  @override
  State<FocusTaskPickerPage> createState() => _FocusTaskPickerPageState();
}

class _FocusTaskPickerPageState extends State<FocusTaskPickerPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Choose Focus Task'),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) {
            final tasks = _filteredTasks();
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children: [
                CupertinoSearchTextField(
                  onChanged: (value) => setState(() => _search = value.trim()),
                ),
                const SizedBox(height: 10),
                if (tasks.isEmpty)
                  const EmptyState(
                    title: 'No available tasks',
                    subtitle: 'Create or uncomplete a task first.',
                  )
                else
                  SectionCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < tasks.length; i++) ...[
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            onPressed: () =>
                                Navigator.of(context).pop(tasks[i].id),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tasks[i].title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: CupertinoColors.label
                                              .resolveFrom(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.state.listNameForTask(tasks[i]),
                                        style: const TextStyle(
                                          color: CupertinoColors.secondaryLabel,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          if (i != tasks.length - 1)
                            Container(
                              margin: const EdgeInsets.only(left: 12),
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
    final query = _search.toLowerCase();
    return widget.state.sortedTasks().where((task) => !task.isCompleted).where((
      task,
    ) {
      if (query.isEmpty) return true;
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          widget.state.listNameForTask(task).toLowerCase().contains(query);
    }).toList();
  }
}
