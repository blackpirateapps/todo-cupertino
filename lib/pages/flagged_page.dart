import 'package:flutter/cupertino.dart';

import '../state/app_state.dart';
import '../widgets/common_widgets.dart';

class FlaggedPage extends StatelessWidget {
  const FlaggedPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Flagged')),
      child: SafeArea(
        child: EmptyState(
          title: 'No flagged tasks yet',
          subtitle: 'Flagging is not implemented yet in this local app.',
          icon: CupertinoIcons.flag,
        ),
      ),
    );
  }
}
