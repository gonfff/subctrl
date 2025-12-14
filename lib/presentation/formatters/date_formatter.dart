import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date, Locale locale) {
  return DateFormat('d MMMM yyyy', locale.toLanguageTag()).format(date);
}
