import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../models/todo_list.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';
import 'list_detail_page.dart';
import 'list_editor_page.dart';
import 'task_editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        CupertinoColors.systemGroupedBackground,
        context,
      ),
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final allTodayTasks = state.tasksDueToday();
            final displayToday = state.homeTodayTasks().take(3).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
              children: [
                _HomeHeader(onAvatarTap: () => _openTaskEditor(context)),
                const SizedBox(height: 10),
                const _SearchShell(),
                const SizedBox(height: 16),
                const _SectionTitle('Today'),
                const SizedBox(height: 8),
                _TodayCard(
                  todayAllCount: allTodayTasks.length,
                  todayCompleted: allTodayTasks
                      .where((t) => t.isCompleted)
                      .length,
                  tasks: displayToday,
                  state: state,
                  onTaskTap: (task) => _openTaskEditor(context, task: task),
                ),
                const SizedBox(height: 18),
                const _SectionTitle('My Lists'),
                const SizedBox(height: 8),
                _MyListsRow(
                  state: state,
                  onListTap: (list) {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) =>
                            ListDetailPage(state: state, list: list),
                      ),
                    );
                  },
                  onAddTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => ListEditorPage(state: state),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Upcoming'),
                const SizedBox(height: 8),
                _UpcomingSection(state: state),
              ],
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = _formatHeaderDate(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(28, 28),
              onPressed: onAvatarTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD8C2), Color(0xFFBE8A62)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.person_fill,
                  size: 18,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              CupertinoIcons.search,
              color: CupertinoColors.secondaryLabel,
              size: 22,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'To-Do',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatHeaderDate(DateTime value) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[value.weekday - 1]}, ${months[value.month - 1]} ${value.day}';
  }
}

class _SearchShell extends StatelessWidget {
  const _SearchShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(
            CupertinoIcons.search,
            size: 18,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Search',
              style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            ),
          ),
          Icon(CupertinoIcons.mic, size: 18, color: CupertinoColors.systemGrey),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.black,
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.todayAllCount,
    required this.todayCompleted,
    required this.tasks,
    required this.state,
    required this.onTaskTap,
  });

  final int todayAllCount;
  final int todayCompleted;
  final List<Task> tasks;
  final AppState state;
  final void Function(Task task) onTaskTap;

  @override
  Widget build(BuildContext context) {
    final total = todayAllCount == 0 ? 1 : todayAllCount;
    final progress = todayCompleted / total;

    return SectionCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(112),
                  painter: _RingPainter(progress: progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$todayCompleted/$todayAllCount',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: tasks.isEmpty
                ? const Text(
                    'No tasks due today',
                    style: TextStyle(color: CupertinoColors.secondaryLabel),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < tasks.length; i++) ...[
                        _TodayTaskRow(
                          task: tasks[i],
                          listName: state.listNameForTask(tasks[i]),
                          onTap: () => onTaskTap(tasks[i]),
                          onToggle: () =>
                              state.toggleTaskCompleted(tasks[i].id),
                        ),
                        if (i != tasks.length - 1)
                          Container(
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
      ),
    );
  }
}

class _TodayTaskRow extends StatelessWidget {
  const _TodayTaskRow({
    required this.task,
    required this.listName,
    required this.onTap,
    required this.onToggle,
  });

  final Task task;
  final String listName;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                task.isCompleted
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                size: 20,
                color: task.isCompleted
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.inactiveGray,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$listName • ${task.priority.label}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyListsRow extends StatelessWidget {
  const _MyListsRow({
    required this.state,
    required this.onListTap,
    required this.onAddTap,
  });

  final AppState state;
  final void Function(TodoList list) onListTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final lists = state.lists.take(3).toList();

    return SizedBox(
      height: 106,
      child: Row(
        children: [
          for (final list in lists) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => onListTap(list),
                child: _ListTileCard(
                  list: list,
                  count: state.tasksForList(list.id).length,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondarySystemGroupedBackground,
                    context,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.add,
                    size: 30,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({required this.list, required this.count});

  final TodoList list;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: CupertinoColors.activeBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(list.icon, color: CupertinoColors.white, size: 18),
          ),
          const Spacer(),
          Text(
            list.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count tasks',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = state
        .tasksWithDueDate()
        .where((t) => t.dueDate != null && !isSameDate(t.dueDate!, now))
        .take(5)
        .toList();

    if (upcoming.isEmpty) {
      return const SectionCard(
        child: Text(
          'No upcoming tasks',
          style: TextStyle(color: CupertinoColors.secondaryLabel),
        ),
      );
    }

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < upcoming.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Icon(
                    upcoming[i].isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                    size: 20,
                    color: upcoming[i].isCompleted
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.inactiveGray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      upcoming[i].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatTimeOnly(upcoming[i].dueDate!),
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (i != upcoming.length - 1)
              Container(
                margin: const EdgeInsets.only(left: 36),
                height: 0.4,
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.separator,
                  context,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE4E7EE);

    final blue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF168BFF);

    final orange = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFF8A1E);

    canvas.drawArc(rect, 0, 6.283, false, track);

    const start = -1.5708;
    const orangeSweep = 1.85;
    canvas.drawArc(rect, start, orangeSweep, false, orange);
    canvas.drawArc(
      rect,
      start + orangeSweep + 0.12,
      (6.283 - 0.12) * progress,
      false,
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
