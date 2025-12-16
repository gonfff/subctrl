import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/entities/tag.dart';

void main() {
  test('copyWith overrides provided fields and keeps others', () {
    const source = Tag(id: 1, name: 'Entertainment', colorHex: '#FF0000');

    final copy = source.copyWith(name: 'Bills');

    expect(copy.id, 1);
    expect(copy.name, 'Bills');
    expect(copy.colorHex, '#FF0000');
  });
}
