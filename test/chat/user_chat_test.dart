import 'package:doctro/features/consultation/chat/models/user_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserChat.fromMap', () {
    test('reads string fields and the supplied id', () {
      final chat = UserChat.fromMap('doc-1', {
        'userId': 'user-1',
        'nickname': 'Dr. Rao',
        'photoUrl': 'https://example.com/a.png',
        'content': 'hello',
        'shopId': 'shop-1',
        'userType': 'doctor',
        'doctorId': 'doc-1',
        'pushToken': 'tok',
      });

      expect(chat.id, 'doc-1');
      expect(chat.userId, 'user-1');
      expect(chat.nickname, 'Dr. Rao');
      expect(chat.content, 'hello');
      expect(chat.token, 'tok');
    });

    test('missing and non-string fields become empty strings', () {
      final chat = UserChat.fromMap('doc-2', {
        'nickname': 'Dr. Rao',
        // A number must not crash the cast to String.
        'pushToken': 12345,
        'shopId': null,
      });

      expect(chat.nickname, 'Dr. Rao');
      expect(chat.token, '');
      expect(chat.shopId, '');
      // Absent keys are treated the same as null.
      expect(chat.content, '');
      expect(chat.photoUrl, '');
      expect(chat.userId, '');
    });

    test('an empty field map yields all empty strings', () {
      final chat = UserChat.fromMap('doc-3', const {});

      expect(chat.id, 'doc-3');
      expect(chat.nickname, '');
      expect(chat.userType, '');
      expect(chat.doctorId, '');
    });
  });
}
