class ChaiUser {
  final String username;
  final String picUrl;
  final String displayName;
  final String bio;

  ChaiUser({this.username, this.picUrl, this.displayName, this.bio});

  factory ChaiUser.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final username = data['username'] as String;
    final picUrl = data['picUrl'] as String;
    final displayName = data['displayName'] as String;
    final bio = data['bio'] as String;
    return ChaiUser(
        username: username, picUrl: picUrl, displayName: displayName, bio: bio);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'picUrl': picUrl,
      'displayName': displayName,
      'bio': bio,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChaiUser &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}
