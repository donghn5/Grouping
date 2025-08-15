class UserProfile {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  UserProfile({required this.uid, this.name, this.email, this.photoUrl});

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) => UserProfile(
    uid: uid,
    name: m['name'] as String?,
    email: m['email'] as String?,
    photoUrl: m['photoUrl'] as String?,
  );
}
