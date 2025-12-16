import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subtrackr/application/tags/create_tag_use_case.dart';
import 'package:subtrackr/application/tags/delete_tag_use_case.dart';
import 'package:subtrackr/application/tags/update_tag_use_case.dart';
import 'package:subtrackr/application/tags/watch_tags_use_case.dart';
import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/presentation/viewmodels/tag_settings_view_model.dart';

class _MockWatchTagsUseCase extends Mock implements WatchTagsUseCase {}

class _MockCreateTagUseCase extends Mock implements CreateTagUseCase {}

class _MockUpdateTagUseCase extends Mock implements UpdateTagUseCase {}

class _MockDeleteTagUseCase extends Mock implements DeleteTagUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Tag(id: 1, name: 'fallback', colorHex: '#FFFFFF'),
    );
  });

  late _MockWatchTagsUseCase watchTagsUseCase;
  late _MockCreateTagUseCase createTagUseCase;
  late _MockUpdateTagUseCase updateTagUseCase;
  late _MockDeleteTagUseCase deleteTagUseCase;
  late StreamController<List<Tag>> tagsController;
  late TagSettingsViewModel viewModel;

  setUp(() {
    watchTagsUseCase = _MockWatchTagsUseCase();
    createTagUseCase = _MockCreateTagUseCase();
    updateTagUseCase = _MockUpdateTagUseCase();
    deleteTagUseCase = _MockDeleteTagUseCase();
    tagsController = StreamController<List<Tag>>();

    when(() => watchTagsUseCase()).thenAnswer((_) => tagsController.stream);
    when(() => createTagUseCase(
          name: any(named: 'name'),
          colorHex: any(named: 'colorHex'),
        )).thenAnswer(
      (_) async => const Tag(id: 2, name: 'New', colorHex: '#FFAA00'),
    );
    when(() => updateTagUseCase(any())).thenAnswer((_) async {});
    when(() => deleteTagUseCase(any())).thenAnswer((_) async {});

    viewModel = TagSettingsViewModel(
      watchTagsUseCase: watchTagsUseCase,
      createTagUseCase: createTagUseCase,
      updateTagUseCase: updateTagUseCase,
      deleteTagUseCase: deleteTagUseCase,
    );
  });

  tearDown(() async {
    await tagsController.close();
    viewModel.dispose();
  });

  test('emits tags from watchTagsUseCase', () async {
    final tag = const Tag(id: 1, name: 'Entertainment', colorHex: '#123456');
    tagsController.add([tag]);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.tags, equals([tag]));
    expect(viewModel.isLoading, isFalse);
  });

  test('create/update/delete delegate to respective use cases', () async {
    await viewModel.createTag(name: 'Games', colorHex: '#FF00FF');
    verify(
      () => createTagUseCase(name: 'Games', colorHex: '#FF00FF'),
    ).called(1);

    final tag = const Tag(id: 3, name: 'Bills', colorHex: '#000000');
    await viewModel.updateTag(tag);
    verify(() => updateTagUseCase(tag)).called(1);

    await viewModel.deleteTag(3);
    verify(() => deleteTagUseCase(3)).called(1);
  });
}
