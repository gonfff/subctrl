const bool kEnableTestingDateOverride = bool.fromEnvironment(
  'ENABLE_TESTING_DATE',
  defaultValue: false,
);

class AppClock {
  DateTime? _overrideDate;

  DateTime now() {
    final overrideDate = _overrideDate;
    if (overrideDate == null) {
      return DateTime.now();
    }
    final systemNow = DateTime.now();
    return DateTime(
      overrideDate.year,
      overrideDate.month,
      overrideDate.day,
      systemNow.hour,
      systemNow.minute,
      systemNow.second,
      systemNow.millisecond,
      systemNow.microsecond,
    );
  }

  DateTime? get overrideDate => _overrideDate;

  void setOverrideDate(DateTime? value) {
    if (value == null) {
      _overrideDate = null;
      return;
    }
    _overrideDate = DateTime(value.year, value.month, value.day);
  }
}
