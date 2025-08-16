import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupsRepository {
  final _col = FirebaseFirestore.instance.collection('groups');

  Stream<List<Group>> watchMyGroups(String uid) {
    return _col.where('memberIds', arrayContains: uid).snapshots().map(
      (s) => s.docs.map((d) => Group.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<String> createGroup({
    required String name,
    required String ownerId,
    String? colorHex,
  }) async {
    final doc = _col.doc();
    await doc.set({
      'name': name.trim(),
      'ownerId': ownerId,
      'memberIds': [ownerId],
      if (colorHex != null) 'colorHex': colorHex,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // 👇 추가
  Future<void> deleteGroup(String groupId) => _col.doc(groupId).delete();

  Future<void> leaveGroup({required String groupId, required String uid}) =>
      _col.doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
        Future<void> addMembers({required String groupId, required List<String> uids}) =>
      _col.doc(groupId).update({
        'memberIds': FieldValue.arrayUnion(uids),
        'updatedAt': FieldValue.serverTimestamp(),
      });
}

