import 'package:drift/drift.dart';

class CurrenciesTable extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {code};
}
