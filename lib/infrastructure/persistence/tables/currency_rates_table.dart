import 'package:drift/drift.dart';

class CurrencyRatesTable extends Table {
  TextColumn get baseCode => text()();
  TextColumn get quoteCode => text()();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {baseCode, quoteCode};
}
