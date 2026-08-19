import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FieldValidators.name', () {
    test('rejects empty', () {
      expect(FieldValidators.name(''), 'error_name_required');
    });
    test('accepts Devanagari names', () {
      expect(FieldValidators.name('प्रेम कुमार'), isNull);
    });
    test('rejects single character', () {
      expect(FieldValidators.name('P'), 'error_name_invalid');
    });
  });

  group('FieldValidators.phone', () {
    test('accepts valid 10-digit Indian mobile', () {
      expect(FieldValidators.phone('9625460555'), isNull);
    });
    test('rejects numbers starting with 0-5', () {
      expect(FieldValidators.phone('5625460555'), 'error_phone_invalid');
    });
    test('rejects wrong length', () {
      expect(FieldValidators.phone('96254605'), 'error_phone_invalid');
    });
  });

  group('FieldValidators.emailOptional', () {
    test('empty is valid (optional field)', () {
      expect(FieldValidators.emailOptional(''), isNull);
    });
    test('rejects malformed email', () {
      expect(
        FieldValidators.emailOptional('not-an-email'),
        'error_email_invalid',
      );
    });
    test('accepts valid email', () {
      expect(
        FieldValidators.emailOptional('geekymantu@gmail.com'),
        isNull,
      );
    });
  });

  group('FieldValidators.emailRequired', () {
    test('rejects empty', () {
      expect(FieldValidators.emailRequired(''), 'error_email_required');
    });
    test('rejects malformed email', () {
      expect(FieldValidators.emailRequired('nope'), 'error_email_invalid');
    });
    test('accepts a valid email', () {
      expect(FieldValidators.emailRequired('admin@dhammapath.app'), isNull);
    });
  });

  group('FieldValidators.passwordRequired', () {
    test('rejects empty', () {
      expect(FieldValidators.passwordRequired(''), 'error_password_required');
    });
    test('accepts any non-empty password', () {
      expect(FieldValidators.passwordRequired('secret'), isNull);
    });
  });

  group('FieldValidators.licenceRequired', () {
    test('rejects empty licence — copyright is the top launch risk', () {
      expect(FieldValidators.licenceRequired(''), 'error_licence_required');
    });
    test('accepts a provided licence', () {
      expect(FieldValidators.licenceRequired('own-artwork'), isNull);
    });
  });

  group('FieldValidators.teacherSelectionRequired', () {
    test('rejects empty selection', () {
      expect(
        FieldValidators.teacherSelectionRequired(const []),
        'error_teacher_required',
      );
    });
    test('accepts one or more teachers', () {
      expect(
        FieldValidators.teacherSelectionRequired(const ['buddha']),
        isNull,
      );
    });
  });
}
