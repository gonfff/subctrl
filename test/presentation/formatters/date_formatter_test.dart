import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:subctrl/presentation/formatters/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ru');
  });

  test('formatDate renders English month names', () {
    final result = formatDate(DateTime(2024, 1, 2), const Locale('en'));

    expect(result, '2 January 2024');
  });

  test('formatDate renders Russian month names', () {
    final result = formatDate(DateTime(2024, 1, 2), const Locale('ru'));

    expect(result, '2 января 2024');
  });
}
