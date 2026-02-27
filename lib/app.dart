import 'package:flutter/cupertino.dart';

import 'models/task.dart';
import 'pages/all_tasks_page.dart';
import 'pages/focus_page.dart';
import 'pages/home_page.dart';
import 'pages/lists_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'state/app_state.dart';
import 'widgets/quick_add_overlay.dart';

class TodoCupertinoApp extends StatelessWidget {
  const TodoCupertinoApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
            primaryColor: CupertinoColors.activeBlue,
          ),
          home: AppShell(state: state),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final CupertinoTabController _tabController;
  static const _focusTabIndex = 3;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startFocusForTask(Task task) {
    widget.state.setFocusTask(task.id, requestStart: true);
    _tabController.index = _focusTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled_solid),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.tray_full),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.timer),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: HomePage(state: state, onStartFocus: _startFocusForTask),
              ),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: AllTasksPage(
                  state: state,
                  onStartFocus: _startFocusForTask,
                ),
              ),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: ListsPage(
                  state: state,
                  onStartFocus: _startFocusForTask,
                ),
              ),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: FocusPage(state: state),
              ),
            );
          case 4:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: StatsPage(state: state),
              ),
            );
          case 5:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: SettingsPage(state: state),
              ),
            );
          default:
            return CupertinoTabView(
              builder: (context) => QuickAddOverlay(
                state: state,
                child: HomePage(state: state, onStartFocus: _startFocusForTask),
              ),
            );
        }
      },
    );
  }
}
