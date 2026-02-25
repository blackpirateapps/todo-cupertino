import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../utils/app_utils.dart';
import 'common_widgets.dart';

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
    final isOverdue =
        task.dueDate != null &&
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
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
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
                            Pill(
                              text: task.project!,
                              icon: CupertinoIcons.folder_solid,
                            ),
                          if (task.dueDate != null)
                            Pill(
                              text: formatDateTime(task.dueDate!),
                              icon: CupertinoIcons.calendar,
                              color: isOverdue
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.activeBlue,
                            ),
                          if (task.subtasks.isNotEmpty)
                            Pill(
                              text:
                                  '${task.completedSubtaskCount}/${task.subtasks.length} subtasks',
                              icon: CupertinoIcons.check_mark_circled,
                            ),
                          for (final tag in task.tags.take(4))
                            Pill(text: '#$tag', icon: CupertinoIcons.tag_solid),
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
