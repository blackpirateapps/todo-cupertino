import 'dart:math';

import 'package:flutter/cupertino.dart';

final Random _random = Random();

String generateId() {
  final t = DateTime.now().microsecondsSinceEpoch;
  final r = _random.nextInt(1 << 32);
  return '$t-$r';
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDateTime(DateTime value) {
  const monthNames = <String>[
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
  final month = monthNames[value.month - 1];
  final day = value.day.toString();
  final year = value.year;

  var hour = value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '$month $day, $year  $hour:$minute $suffix';
}

String formatTimeOnly(DateTime value) {
  var hour = value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;
  return '$hour:$minute $suffix';
}

const Map<String, IconData> kListIconMap = {
  'person_fill': CupertinoIcons.person_fill,
  'briefcase_fill': CupertinoIcons.briefcase_fill,
  'cart_fill': CupertinoIcons.cart_fill,
  'house_fill': CupertinoIcons.house_fill,
  'book_fill': CupertinoIcons.book_fill,
  'heart_fill': CupertinoIcons.heart_fill,
  'airplane': CupertinoIcons.airplane,
  'folder_fill': CupertinoIcons.folder_fill,
  'star_fill': CupertinoIcons.star_fill,
  'game_controller_fill': CupertinoIcons.circle_fill,
};

IconData iconForKey(String key) {
  return kListIconMap[key] ?? CupertinoIcons.folder_fill;
}
