import 'package:drift/drift.dart';

class SubscriptionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  IntColumn get cycle => integer()();
  DateTimeColumn get purchaseDate => dateTime()();
  DateTimeColumn get nextPaymentDate => dateTime()();
  IntColumn get tagId => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get statusChangedAt => dateTime().withDefault(currentDateAndTime)();
}
