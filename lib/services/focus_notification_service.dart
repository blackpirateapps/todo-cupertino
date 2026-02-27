import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FocusNotificationService {
  FocusNotificationService._();

  static final FocusNotificationService instance = FocusNotificationService._();
  static const int _notificationId = 91231;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> showRunning({
    required String title,
    required String body,
  }) async {
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_timer_channel',
        'Focus Timer',
        channelDescription: 'Live timer while focus session is running',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showWhen: false,
      ),
    );
    await _plugin.show(_notificationId, title, body, details);
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    await _plugin.cancel(_notificationId);
  }
}
