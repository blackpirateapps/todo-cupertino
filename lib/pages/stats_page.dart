import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Stats')),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final completedSeries = _completedByDay(state);
            final focusByList = _focusByList(state);
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children: [
                const Text(
                  'Tasks Done Per Day',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SectionCard(
                  child: SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        lineTouchData: LineTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 26,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 2,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= completedSeries.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  completedSeries[i].label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            barWidth: 4,
                            color: CupertinoColors.systemBlue,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: CupertinoColors.systemBlue.withValues(
                                alpha: 0.18,
                              ),
                            ),
                            spots: [
                              for (var i = 0; i < completedSeries.length; i++)
                                FlSpot(
                                  i.toDouble(),
                                  completedSeries[i].value.toDouble(),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Focus Minutes By List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SectionCard(
                  child: SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _maxBarY(focusByList),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= focusByList.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    focusByList[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: CupertinoColors.secondaryLabel,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < focusByList.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: focusByList[i].value.toDouble(),
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    colors: [
                                      _palette[i % _palette.length],
                                      _palette[(i + 2) % _palette.length],
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_Point> _completedByDay(AppState state) {
    final now = DateTime.now();
    final items = <_Point>[];
    for (var i = 13; i >= 0; i--) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final count = state.tasks
          .where((task) => task.isCompleted && isSameDate(task.updatedAt, day))
          .length;
      items.add(_Point(label: '${day.month}/${day.day}', value: count));
    }
    return items;
  }

  List<_Point> _focusByList(AppState state) {
    return state.lists.map((list) {
      final total = state
          .tasksForList(list.id)
          .fold<int>(0, (sum, task) => sum + task.focusAccumulatedMinutes);
      return _Point(label: list.name, value: total);
    }).toList();
  }

  double _maxBarY(List<_Point> points) {
    var maxVal = 10;
    for (final p in points) {
      if (p.value > maxVal) maxVal = p.value;
    }
    return (maxVal * 1.2).ceilToDouble();
  }
}

class _Point {
  const _Point({required this.label, required this.value});

  final String label;
  final int value;
}

const _palette = <Color>[
  CupertinoColors.systemBlue,
  CupertinoColors.systemPink,
  CupertinoColors.systemGreen,
  CupertinoColors.systemOrange,
  CupertinoColors.systemTeal,
  CupertinoColors.systemPurple,
];
