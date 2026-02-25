import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';
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
            final snapshot = _HomeDashboardSnapshot.fromState(state);
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
                  summary: snapshot.todaySummary,
                  onTaskTap: (task) {
                    if (task == null) return;
                    _openTaskEditor(context, task: task);
                  },
                  onToggleTask: (task) {
                    if (task == null) return;
                    state.toggleTaskCompleted(task.id);
                  },
                ),
                const SizedBox(height: 18),
                const _SectionTitle('My Lists'),
                const SizedBox(height: 8),
                _ListTilesRow(
                  items: snapshot.listSummaries,
                  onAddTap: () => _openTaskEditor(context),
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Upcoming'),
                const SizedBox(height: 8),
                for (final group in snapshot.upcomingGroups) ...[
                  _UpcomingGroupCard(group: group),
                  const SizedBox(height: 10),
                ],
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
    required this.summary,
    required this.onTaskTap,
    required this.onToggleTask,
  });

  final _TodaySummary summary;
  final void Function(Task? task) onTaskTap;
  final void Function(Task? task) onToggleTask;

  @override
  Widget build(BuildContext context) {
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
                  painter: _RingPainter(progress: summary.progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary.completed}/${summary.total}',
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
            child: Column(
              children: [
                for (var i = 0; i < summary.rows.length; i++) ...[
                  _TodayTaskRow(
                    row: summary.rows[i],
                    onTap: () => onTaskTap(summary.rows[i].task),
                    onToggle: () => onToggleTask(summary.rows[i].task),
                  ),
                  if (i != summary.rows.length - 1)
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
    required this.row,
    required this.onTap,
    required this.onToggle,
  });

  final _TodayTaskRowData row;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: row.task == null ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            GestureDetector(
              onTap: row.task == null ? null : onToggle,
              child: Icon(
                row.isCompleted
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                size: 20,
                color: row.isCompleted
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
                    row.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                      decoration: row.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (row.badgeText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: row.badgeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          row.badgeText!,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

class _ListTilesRow extends StatelessWidget {
  const _ListTilesRow({required this.items, required this.onAddTap});

  final List<_ListSummary> items;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: Row(
        children: [
          for (final item in items) ...[
            Expanded(child: _ListTileCard(item: item)),
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
  const _ListTileCard({required this.item});

  final _ListSummary item;

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
              color: item.color,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: CupertinoColors.white, size: 18),
          ),
          const Spacer(),
          Text(
            item.title,
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
            '${item.taskCount} tasks',
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

class _UpcomingGroupCard extends StatelessWidget {
  const _UpcomingGroupCard({required this.group});

  final _UpcomingGroup group;

  @override
  Widget build(BuildContext context) {
    final separator = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: separator, width: 0.4)),
            ),
            child: Text(
              group.label,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (var i = 0; i < group.items.length; i++) ...[
            _UpcomingRow(item: group.items[i]),
            if (i != group.items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Container(height: 0.4, color: separator),
              ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.item});

  final _UpcomingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Icon(
            item.isCompleted
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.circle,
            size: 20,
            color: item.isCompleted
                ? CupertinoColors.activeBlue
                : CupertinoColors.inactiveGray,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.black,
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (item.timeLabel != null)
            Text(
              item.timeLabel!,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
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

class _HomeDashboardSnapshot {
  _HomeDashboardSnapshot({
    required this.todaySummary,
    required this.listSummaries,
    required this.upcomingGroups,
  });

  final _TodaySummary todaySummary;
  final List<_ListSummary> listSummaries;
  final List<_UpcomingGroup> upcomingGroups;

  factory _HomeDashboardSnapshot.fromState(AppState state) {
    final sorted = state.sortedTasks();
    final now = DateTime.now();
    final todayTasks = state.tasksDueToday();
    final totalForRing = todayTasks.isEmpty
        ? 6
        : todayTasks.length.clamp(1, 99) as int;
    final completedForRing = todayTasks.isEmpty
        ? 4
        : todayTasks.where((t) => t.isCompleted).length.clamp(0, totalForRing)
              as int;

    final todayRows = <_TodayTaskRowData>[];
    for (final task in todayTasks.take(3)) {
      final badge = task.dueDate != null ? formatTimeOnly(task.dueDate!) : null;
      todayRows.add(
        _TodayTaskRowData(
          title: task.title,
          badgeText: badge,
          badgeColor: const Color(0xFF1677FF),
          isCompleted: task.isCompleted,
          task: task,
        ),
      );
    }
    if (todayRows.isEmpty) {
      todayRows.addAll(const [
        _TodayTaskRowData(
          title: 'Morning Meeting',
          badgeText: '9 50 AM',
          badgeColor: Color(0xFF1677FF),
          isCompleted: false,
        ),
        _TodayTaskRowData(
          title: 'Grocery Shopping',
          badgeText: '5 60 PM',
          badgeColor: Color(0xFF34C759),
          isCompleted: false,
        ),
        _TodayTaskRowData(title: 'Read Book', isCompleted: false),
      ]);
    } else {
      while (todayRows.length < 3) {
        todayRows.add(
          const _TodayTaskRowData(
            title: 'Open All tab to add more',
            isCompleted: false,
          ),
        );
      }
    }

    final byProject = state.tasksByProject();
    final preferred = ['Personal', 'Work', 'Groceries'];
    final colors = [
      const Color(0xFF1F8BFF),
      const Color(0xFFFF9500),
      const Color(0xFF34C759),
    ];
    final icons = [
      CupertinoIcons.person_fill,
      CupertinoIcons.briefcase_fill,
      CupertinoIcons.cart_fill,
    ];

    final listSummaries = <_ListSummary>[];
    for (var i = 0; i < preferred.length; i++) {
      final key = preferred[i];
      final actual = byProject[key]?.length;
      final fallbackCounts = [12, 8, 5];
      listSummaries.add(
        _ListSummary(
          title: key,
          taskCount: actual ?? fallbackCounts[i],
          color: colors[i],
          icon: icons[i],
        ),
      );
    }

    final upcoming =
        sorted
            .where((t) => t.dueDate != null && !isSameDate(t.dueDate!, now))
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final groupsByLabel = <String, List<_UpcomingItem>>{};
    for (final task in upcoming.take(5)) {
      final due = task.dueDate!;
      final tomorrow = now.add(const Duration(days: 1));
      final label = isSameDate(due, tomorrow)
          ? 'Tomorrow'
          : _groupDateLabel(due);
      groupsByLabel
          .putIfAbsent(label, () => [])
          .add(
            _UpcomingItem(
              title: task.title,
              timeLabel: formatTimeOnly(due),
              isCompleted: task.isCompleted,
            ),
          );
    }

    final upcomingGroups = groupsByLabel.entries
        .map((e) => _UpcomingGroup(label: e.key, items: e.value))
        .toList();

    if (upcomingGroups.isEmpty) {
      upcomingGroups.addAll(const [
        _UpcomingGroup(
          label: 'Tomorrow',
          items: [
            _UpcomingItem(title: 'Dentist Appointment', timeLabel: '10:00 AM'),
            _UpcomingItem(title: 'Submit Report', timeLabel: '2:00 PM'),
          ],
        ),
        _UpcomingGroup(
          label: 'Thursday, Oct 28',
          items: [
            _UpcomingItem(title: 'Lunch with Sarah', timeLabel: '12:30 PM'),
          ],
        ),
      ]);
    }

    return _HomeDashboardSnapshot(
      todaySummary: _TodaySummary(
        completed: completedForRing,
        total: totalForRing,
        rows: todayRows.take(3).toList(),
      ),
      listSummaries: listSummaries,
      upcomingGroups: upcomingGroups,
    );
  }

  static String _groupDateLabel(DateTime value) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[value.weekday - 1]}, ${months[value.month - 1]} ${value.day}';
  }
}

class _TodaySummary {
  const _TodaySummary({
    required this.completed,
    required this.total,
    required this.rows,
  });

  final int completed;
  final int total;
  final List<_TodayTaskRowData> rows;

  double get progress => total == 0 ? 0 : completed / total;
}

class _TodayTaskRowData {
  const _TodayTaskRowData({
    required this.title,
    this.badgeText,
    this.badgeColor = const Color(0xFF1677FF),
    this.isCompleted = false,
    this.task,
  });

  final String title;
  final String? badgeText;
  final Color badgeColor;
  final bool isCompleted;
  final Task? task;
}

class _ListSummary {
  const _ListSummary({
    required this.title,
    required this.taskCount,
    required this.color,
    required this.icon,
  });

  final String title;
  final int taskCount;
  final Color color;
  final IconData icon;
}

class _UpcomingGroup {
  const _UpcomingGroup({required this.label, required this.items});

  final String label;
  final List<_UpcomingItem> items;
}

class _UpcomingItem {
  const _UpcomingItem({
    required this.title,
    this.timeLabel,
    this.isCompleted = false,
  });

  final String title;
  final String? timeLabel;
  final bool isCompleted;
}
