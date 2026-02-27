import 'package:flutter/cupertino.dart';

import '../state/app_state.dart';
import '../widgets/common_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                SectionCard(
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.moon_fill, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CupertinoSwitch(
                        value: state.isDarkMode,
                        onChanged: state.setDarkMode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pomodoro Defaults',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DurationRow(
                        label: 'Focus length',
                        value: state.pomodoroMinutes,
                        onMinus: () =>
                            state.setPomodoroMinutes(state.pomodoroMinutes - 1),
                        onPlus: () =>
                            state.setPomodoroMinutes(state.pomodoroMinutes + 1),
                      ),
                      const SizedBox(height: 8),
                      _DurationRow(
                        label: 'Break length',
                        value: state.breakMinutes,
                        onMinus: () =>
                            state.setBreakMinutes(state.breakMinutes - 1),
                        onPlus: () =>
                            state.setBreakMinutes(state.breakMinutes + 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All tasks and settings are stored locally on the device using SharedPreferences.',
                        style: TextStyle(fontSize: 14),
                      ),
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
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(28),
          onPressed: onMinus,
          child: const Icon(CupertinoIcons.minus_circle),
        ),
        const SizedBox(width: 8),
        Text('$value min', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(28),
          onPressed: onPlus,
          child: const Icon(CupertinoIcons.add_circled),
        ),
      ],
    );
  }
}
