class ChaiUser {
  final String id;
  final String username;
  final String picUrl;
  final String displayName;
  final String bio;
  final int followersCount;
  final int followingCount;
  final List<String> followedByIds;

  ChaiUser(
      {this.id,
      this.username,
      this.picUrl,
      this.displayName,
      this.bio,
      this.followersCount,
      this.followingCount,
      this.followedByIds});

  factory ChaiUser.fromMap(Map<String, dynamic> data, String id) {
    if (data == null || id == null) {
      return null;
    }
    final username = data['username'] as String;
    final picUrl = data['picUrl'] as String;
    final displayName = data['displayName'] as String;
    final bio = data['bio'] as String;
    final followersCount = data['followersCount'] as int ?? 0;
    final followingCount = data['followingCount'] as int ?? 0;
    final followedByIds =
        List<String>.from(data['followedByIds'] ?? List.empty());
    return ChaiUser(
        id: id,
        username: username,
        picUrl: picUrl,
        displayName: displayName,
        bio: bio,
        followersCount: followersCount,
        followingCount: followingCount,
        followedByIds: followedByIds);
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

  Map<String, dynamic> toMap({bool basicInfo = false}) {
    if (basicInfo)
      return {
        'username': username,
        'picUrl': picUrl,
        'displayName': displayName,
        'id': id
      };

    return {
      'username': username,
      'picUrl': picUrl,
      'displayName': displayName,
      'bio': bio,
      // search fields
      '_searchUsername': username.toLowerCase(),
      '_searchDisplayName': displayName.toLowerCase(),
      // users must 'follow' themselves to see their own posts in timeline
      'followedByIds': [id]
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChaiUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
