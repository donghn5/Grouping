class Group {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final String? colorHex;

  Group({required this.id, required this.name, required this.ownerId, required this.memberIds, this.colorHex});

  factory Group.fromMap(String id, Map<String, dynamic> m) => Group(
    id: id,
    name: m['name'] as String,
    ownerId: m['ownerId'] as String,
    memberIds: List<String>.from(m['memberIds'] ?? const []),
    colorHex: m['colorHex'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'ownerId': ownerId,
    'memberIds': memberIds,
    if (colorHex != null) 'colorHex': colorHex,
    'createdAt': DateTime.now(),
  };
}
