import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/tags/create_tag_use_case.dart';
import 'package:subctrl/application/tags/delete_tag_use_case.dart';
import 'package:subctrl/application/tags/update_tag_use_case.dart';
import 'package:subctrl/application/tags/watch_tags_use_case.dart';
import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/repositories/tag_repository.dart';

class _MockTagRepository extends Mock implements TagRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Tag(id: 0, name: 'fallback', colorHex: '#000000'),
    );
  });

  late _MockTagRepository repository;

  setUp(() {
    repository = _MockTagRepository();
  });

  test('WatchTagsUseCase returns stream from repository', () async {
    final controller = StreamController<List<Tag>>();
    when(repository.watchTags).thenAnswer((_) => controller.stream);
    final useCase = WatchTagsUseCase(repository);
    final sample = const Tag(id: 1, name: 'Bills', colorHex: '#FFFFFF');
    final expectation = expectLater(
      useCase(),
      emitsInOrder([
        [sample],
      ]),
    );
    controller.add([sample]);
    await controller.close();
    await expectation;
  });

  test('CreateTagUseCase forwards values to repository', () async {
    when(
      () => repository.createTag(
        name: any(named: 'name'),
        colorHex: any(named: 'colorHex'),
      ),
    ).thenAnswer(
      (_) async => const Tag(id: 2, name: 'Games', colorHex: '#000000'),
    );
    final useCase = CreateTagUseCase(repository);
    final result = await useCase(name: 'Games', colorHex: '#000000');
    expect(result.name, 'Games');
    verify(
      () => repository.createTag(name: 'Games', colorHex: '#000000'),
    ).called(1);
  });

  test('UpdateTagUseCase delegates to repository', () async {
    when(() => repository.updateTag(any())).thenAnswer((_) async {});
    final useCase = UpdateTagUseCase(repository);
    const tag = Tag(id: 3, name: 'Fun', colorHex: '#123456');
    await useCase(tag);
    verify(() => repository.updateTag(tag)).called(1);
  });

  test('DeleteTagUseCase delegates to repository', () async {
    when(() => repository.deleteTag(any())).thenAnswer((_) async {});
    final useCase = DeleteTagUseCase(repository);
    await useCase(7);
    verify(() => repository.deleteTag(7)).called(1);
  });
}
