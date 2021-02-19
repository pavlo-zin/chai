import 'package:chai/models/chai_user.dart';

class Post {
  final ChaiUser userInfo;
  final String postText;
  final DateTime timestamp;

  Post(
      {this.userInfo,
      this.postText,
      this.timestamp});

  factory Post.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final userInfo = ChaiUser.fromMap(data['userInfo']);
    final postText = data['postText'] as String;
    final timestamp = data['timestamp'] as int;
    return Post(
        userInfo: userInfo,
        postText: postText,
        timestamp: DateTime.fromMicrosecondsSinceEpoch(timestamp));
  }

  Map<String, dynamic> toMap() {
    return {
      'userInfo': userInfo.toMap(),
      'postText': postText,
      'timestamp': timestamp.microsecondsSinceEpoch,
    };
  }
}
