import 'package:flutter/cupertino.dart';

import 'pages/all_tasks_page.dart';
import 'pages/flagged_page.dart';
import 'pages/home_page.dart';
import 'pages/scheduled_page.dart';
import 'pages/settings_page.dart';
import 'state/app_state.dart';

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

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled_solid),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Scheduled',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.tray_full),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flag),
            label: 'Flagged',
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
              builder: (context) => HomePage(state: state),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => ScheduledPage(state: state),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => AllTasksPage(state: state),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => FlaggedPage(state: state),
            );
          case 4:
            return CupertinoTabView(
              builder: (context) => SettingsPage(state: state),
            );
          default:
            return CupertinoTabView(
              builder: (context) => HomePage(state: state),
            );
        }
      },
    );
  }
}
