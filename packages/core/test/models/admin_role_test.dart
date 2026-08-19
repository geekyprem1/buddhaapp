import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminRole', () {
    test('fromClaims reads role without a hard cast', () {
      expect(AdminRole.fromClaims({'role': 'super_admin'}), 'super_admin');
      expect(AdminRole.fromClaims({'role': 1}), '1');
      expect(AdminRole.fromClaims({}), isNull);
    });

    test('recognises the three launch roles and rejects everything else', () {
      expect(AdminRole.isAdmin(AdminRole.superAdmin), isTrue);
      expect(AdminRole.isAdmin(AdminRole.contentManager), isTrue);
      expect(AdminRole.isAdmin(AdminRole.moderator), isTrue);
      expect(AdminRole.isAdmin(null), isFalse);
      expect(AdminRole.isAdmin('user'), isFalse);
    });

    test('user and config writes stay super-admin only', () {
      expect(AdminRole.canManageUsers(AdminRole.superAdmin), isTrue);
      expect(AdminRole.canManageUsers(AdminRole.contentManager), isFalse);
      expect(AdminRole.canEditConfig(AdminRole.moderator), isFalse);
    });

    test('content managers can edit content; moderators cannot', () {
      expect(AdminRole.canEditContent(AdminRole.contentManager), isTrue);
      expect(AdminRole.canEditContent(AdminRole.moderator), isFalse);
      expect(AdminRole.canModerate(AdminRole.moderator), isTrue);
    });
  });
}
