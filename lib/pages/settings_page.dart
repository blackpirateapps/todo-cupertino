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
