import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_profile.dart';

class FriendsRepository {
  final _users = FirebaseFirestore.instance.collection('users');

  // users/{uid}/friends/{friendUid} 형태의 서브컬렉션을 가정
  Stream<List<UserProfile>> watchFriends(String uid) {
    final ref = _users.doc(uid).collection('friends');
    return ref.snapshots().asyncMap((snap) async {
      final uids = snap.docs.map((d) => d.id).toList();
      if (uids.isEmpty) return <UserProfile>[];

      // whereIn은 10개 제한 → 10개씩 청크
      final chunks = <List<String>>[];
      for (var i = 0; i < uids.length; i += 10) {
        chunks.add(uids.sublist(i, (i + 10).clamp(0, uids.length)));
      }

      final results = <UserProfile>[];
      for (final c in chunks) {
        final q = await _users.where(FieldPath.documentId, whereIn: c).get();
        results.addAll(q.docs.map((d) => UserProfile.fromMap(d.id, d.data())));
      }
      return results;
    });
  }
}

