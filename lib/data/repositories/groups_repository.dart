import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/group.dart';

class GroupsRepository {
  final _col = FirebaseFirestore.instance.collection('groups');

  Stream<List<Group>> watchMyGroups(String uid) {
    return _col.where('memberIds', arrayContains: uid).snapshots().map(
      (s) => s.docs.map((d) => Group.fromMap(d.id, d.data())).toList(),
    );
  }
}

