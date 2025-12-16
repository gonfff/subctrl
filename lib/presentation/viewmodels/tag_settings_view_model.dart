import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:subtrackr/application/tags/create_tag_use_case.dart';
import 'package:subtrackr/application/tags/delete_tag_use_case.dart';
import 'package:subtrackr/application/tags/update_tag_use_case.dart';
import 'package:subtrackr/application/tags/watch_tags_use_case.dart';
import 'package:subtrackr/domain/entities/tag.dart';

class TagSettingsViewModel extends ChangeNotifier {
  TagSettingsViewModel({
    required WatchTagsUseCase watchTagsUseCase,
    required CreateTagUseCase createTagUseCase,
    required UpdateTagUseCase updateTagUseCase,
    required DeleteTagUseCase deleteTagUseCase,
  })  : _watchTagsUseCase = watchTagsUseCase,
        _createTagUseCase = createTagUseCase,
        _updateTagUseCase = updateTagUseCase,
        _deleteTagUseCase = deleteTagUseCase {
    _subscribe();
  }

  final WatchTagsUseCase _watchTagsUseCase;
  final CreateTagUseCase _createTagUseCase;
  final UpdateTagUseCase _updateTagUseCase;
  final DeleteTagUseCase _deleteTagUseCase;

  StreamSubscription<List<Tag>>? _subscription;
  List<Tag> _tags = const [];
  bool _isLoading = true;

  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;

  Future<Tag> createTag({
    required String name,
    required String colorHex,
  }) {
    return _createTagUseCase(name: name, colorHex: colorHex);
  }

  Future<void> updateTag(Tag tag) {
    return _updateTagUseCase(tag);
  }

  Future<void> deleteTag(int id) {
    return _deleteTagUseCase(id);
  }

  Stream<List<Tag>> watchTags() => _watchTagsUseCase();

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _watchTagsUseCase().listen((tags) {
      _tags = tags;
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
