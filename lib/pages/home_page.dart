import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../models/todo_list.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';
import 'list_detail_page.dart';
import 'list_editor_page.dart';
import 'task_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.state, required this.onStartFocus});

  final AppState state;
  final void Function(Task task) onStartFocus;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    bool matchesTask(Task task) {
      if (_searchText.trim().isEmpty) return true;
      final query = _searchText.trim().toLowerCase();
      final listName = widget.state.listNameForTask(task).toLowerCase();
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          listName.contains(query);
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        CupertinoColors.systemGroupedBackground,
        context,
      ),
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: widget.state,
          builder: (context, _) {
            final allTodayTasks = widget.state.tasksDueToday();
            final visibleTodayTasks = allTodayTasks.where(matchesTask).toList();
            final displayToday =
                (_searchText.trim().isEmpty
                        ? widget.state.homeTodayTasks()
                        : widget.state.sortedTasks(visibleTodayTasks))
                    .take(3)
                    .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
              children: [
                _HomeHeader(onAvatarTap: () => _openTaskEditor(context)),
                const SizedBox(height: 10),
                _SearchShell(
                  onChanged: (value) => setState(() => _searchText = value),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Today'),
                const SizedBox(height: 8),
                _TodayCard(
                  todayAllCount: visibleTodayTasks.length,
                  todayCompleted: visibleTodayTasks
                      .where((t) => t.isCompleted)
                      .length,
                  tasks: displayToday,
                  state: widget.state,
                  onTaskTap: (task) => _openTaskEditor(context, task: task),
                  onStartFocus: widget.onStartFocus,
                ),
                const SizedBox(height: 18),
                const _SectionTitle('My Lists'),
                const SizedBox(height: 8),
                _MyListsRow(
                  state: widget.state,
                  onListTap: (list) {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => ListDetailPage(
                          state: widget.state,
                          list: list,
                          onStartFocus: widget.onStartFocus,
                        ),
                      ),
                    );
                  },
                  onAddTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => ListEditorPage(state: widget.state),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Upcoming'),
                const SizedBox(height: 8),
                _UpcomingSection(
                  state: widget.state,
                  onStartFocus: widget.onStartFocus,
                  searchText: _searchText,
                ),
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
        builder: (context) =>
            TaskEditorPage(state: widget.state, initialTask: task),
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
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
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
  const _SearchShell({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoSearchTextField(
        onChanged: onChanged,
        backgroundColor: CupertinoColors.transparent,
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
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.label.resolveFrom(context),
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
    required this.onStartFocus,
  });

  final int todayAllCount;
  final int todayCompleted;
  final List<Task> tasks;
  final AppState state;
  final void Function(Task task) onTaskTap;
  final void Function(Task task) onStartFocus;

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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.label.resolveFrom(context),
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
                          onStartFocus: () => onStartFocus(tasks[i]),
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
    required this.onStartFocus,
  });

  final Task task;
  final String listName;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onStartFocus;

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
                      color: CupertinoColors.label.resolveFrom(context),
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
                  if (task.focusAccumulatedMinutes > 0) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                size: 20,
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
    final lists = state.lists;

    return SizedBox(
      height: 106,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final list in lists) ...[
            SizedBox(
              width: 112,
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
          SizedBox(
            width: 112,
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
            decoration: BoxDecoration(
              color: colorForListKey(list.colorKey),
              shape: BoxShape.circle,
            ),
            child: Icon(list.icon, color: CupertinoColors.white, size: 18),
          ),
          const Spacer(),
          Text(
            list.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
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
  const _UpcomingSection({
    required this.state,
    required this.onStartFocus,
    required this.searchText,
  });

  final AppState state;
  final void Function(Task task) onStartFocus;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final query = searchText.trim().toLowerCase();
    final upcoming = state
        .tasksWithDueDate()
        .where((task) {
          final isUpcoming =
              task.dueDate != null && !isSameDate(task.dueDate!, now);
          if (!isUpcoming) return false;
          if (query.isEmpty) return true;
          final listName = state.listNameForTask(task).toLowerCase();
          return task.title.toLowerCase().contains(query) ||
              task.description.toLowerCase().contains(query) ||
              listName.contains(query);
        })
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.square(24),
                    onPressed: () => state.toggleTaskCompleted(upcoming[i].id),
                    child: Icon(
                      upcoming[i].isCompleted
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      size: 20,
                      color: upcoming[i].isCompleted
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.inactiveGray,
                    ),
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.square(24),
                    onPressed: () => onStartFocus(upcoming[i]),
                    child: const Icon(
                      CupertinoIcons.play_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
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
