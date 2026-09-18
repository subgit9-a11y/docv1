import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/features/consultation/chat/constants/firestore_constants.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String content;
  String shopId;
  String userType;
  String doctorId;
  String token;
  String userId;

  UserChat(
      {required this.id,
      required this.photoUrl,
      required this.nickname,
      required this.content,
      required this.shopId,
      required this.userType,
      required this.doctorId,
      required this.token,
      required this.userId});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.content: content,
      FirestoreConstants.shopId: shopId,
      FirestoreConstants.userType: userType,
      FirestoreConstants.doctorId: doctorId,
      FirestoreConstants.token: token,
      FirestoreConstants.userId: userId
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    return UserChat.fromMap(doc.id, data);
  }

  /// Builds a chat participant from raw Firestore fields. Kept separate from
  /// [UserChat.fromDocument] so the parsing rules are testable without a
  /// live Firestore snapshot.
  factory UserChat.fromMap(String id, Map<String, dynamic> data) {
    String read(String key) {
      final value = data[key];
      return value is String ? value : '';
    }

    return UserChat(
        userId: read(FirestoreConstants.userId),
        id: id,
        photoUrl: read(FirestoreConstants.photoUrl),
        nickname: read(FirestoreConstants.nickname),
        content: read(FirestoreConstants.content),
        shopId: read(FirestoreConstants.shopId),
        userType: read(FirestoreConstants.userType),
        doctorId: read(FirestoreConstants.doctorId),
        token: read(FirestoreConstants.token));
  }
}
