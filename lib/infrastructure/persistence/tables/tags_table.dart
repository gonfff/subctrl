import 'package:drift/drift.dart';

class TagsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get colorHex => text().withLength(min: 4, max: 9)();

}
