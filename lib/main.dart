import 'package:flutter/cupertino.dart';

import 'app.dart';
import 'state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.load();
  runApp(TodoCupertinoApp(state: appState));
}
