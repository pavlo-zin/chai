import 'package:chai/models/chai_user.dart';

class Post {
  final ChaiUser userInfo;
  final String postText;
  final DateTime timestamp;
  final String id;

  Post({this.id, this.userInfo, this.postText, this.timestamp});

  factory Post.fromMap(Map<String, dynamic> data, String postId, String userId) {
    if (data == null) {
      return null;
    }
    final userInfo = ChaiUser.fromPostMap(data['userInfo']);
    final postText = data['postText'] as String;
    final timestamp = data['timestamp'] as int;
    return Post(
        id: postId,
        userInfo: userInfo,
        postText: postText,
        timestamp: DateTime.fromMicrosecondsSinceEpoch(timestamp));
  }

  Map<String, dynamic> toMap() {
    return {
      'userInfo': userInfo.toMap(includeUid: true),
      'postText': postText,
      'timestamp': timestamp.microsecondsSinceEpoch,
    };
  }
}
