import 'dart:math';

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
