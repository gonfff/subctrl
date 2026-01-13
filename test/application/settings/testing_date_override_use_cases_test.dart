import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/settings/get_testing_date_override_use_case.dart';
import 'package:subctrl/application/settings/set_testing_date_override_use_case.dart';
import 'package:subctrl/domain/repositories/settings_repository.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late SettingsRepository repository;

  setUp(() {
    repository = _MockSettingsRepository();
  });

  test('get testing date override returns repository value', () async {
    final value = DateTime(2024, 1, 2);
    when(() => repository.getTestingDateOverride())
        .thenAnswer((_) async => value);

    final useCase = GetTestingDateOverrideUseCase(repository);

    expect(await useCase(), value);
    verify(() => repository.getTestingDateOverride()).called(1);
  });

  test('set testing date override forwards value', () async {
    final value = DateTime(2024, 1, 2);
    when(() => repository.setTestingDateOverride(value))
        .thenAnswer((_) async {});

    final useCase = SetTestingDateOverrideUseCase(repository);

    await useCase(value);

    verify(() => repository.setTestingDateOverride(value)).called(1);
  });
}
