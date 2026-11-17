import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty and malformed addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
    test('accepts a normal address', () {
      expect(Validators.email('sara@example.com'), isNull);
      expect(Validators.email('  sara@example.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('needs 8 characters with letters and numbers', () {
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('onlyletters'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password('Letters123'), isNull);
    });
    test('confirm must match', () {
      expect(Validators.confirmPassword('a', 'b'), isNotNull);
      expect(Validators.confirmPassword('same', 'same'), isNull);
    });
  });

  group('optional validators', () {
    test('empty values are valid', () {
      expect(Validators.optionalPhone(''), isNull);
      expect(Validators.optionalUrl(''), isNull);
      expect(Validators.optionalEmail(''), isNull);
    });
    test('bad values are rejected', () {
      expect(Validators.optionalPhone('abc'), isNotNull);
      expect(Validators.optionalUrl('not a link'), isNotNull);
    });
    test('good values are accepted', () {
      expect(Validators.optionalPhone('+964 750 123 4567'), isNull);
      expect(Validators.optionalUrl('https://example.com/me'), isNull);
    });
  });

  test('name length limits', () {
    expect(Validators.name('A'), isNotNull);
    expect(Validators.name('Sara Ahmed'), isNull);
  });
}
