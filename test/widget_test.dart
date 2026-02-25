import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cupertino/utils/app_utils.dart';

void main() {
  test('formatDateTime includes month and year', () {
    final value = DateTime(2026, 2, 23, 9, 5);
    final formatted = formatDateTime(value);

    expect(formatted, contains('Feb'));
    expect(formatted, contains('2026'));
  });
}
