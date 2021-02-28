class ChaiUser {
  final String id;
  final String username;
  final String picUrl;
  final String displayName;
  final String bio;

  ChaiUser({this.id, this.username, this.picUrl, this.displayName, this.bio});

  factory ChaiUser.fromMap(Map<String, dynamic> data, String id) {
    if (data == null || id == null) {
      return null;
    }
    final username = data['username'] as String;
    final picUrl = data['picUrl'] as String;
    final displayName = data['displayName'] as String;
    final bio = data['bio'] as String;
    return ChaiUser(
        id: id,
        username: username,
        picUrl: picUrl,
        displayName: displayName,
        bio: bio);
  }

  factory ChaiUser.fromPostMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final id = data['id'] as String;
    final username = data['username'] as String;
    final picUrl = data['picUrl'] as String;
    final displayName = data['displayName'] as String;
    final bio = data['bio'] as String;
    return ChaiUser(
        id: id,
        username: username,
        picUrl: picUrl,
        displayName: displayName,
        bio: bio);
  }

  Map<String, dynamic> toMap({bool includeUid = false}) {
    final Map<String, dynamic> user = {
      'username': username,
      'picUrl': picUrl,
      'displayName': displayName,
      'bio': bio,
      // search fields
      '_searchUsername': username.toLowerCase(),
      '_searchDisplayName': displayName.toLowerCase(),
    };
    if (includeUid) {
      user['id'] = id;
    }
    return user;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChaiUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
