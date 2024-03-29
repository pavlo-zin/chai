import 'dart:ui';

import 'package:chai/models/chai_user.dart';

class PostImageInfo {
  final String url;
  final Size size;
  final Color placeholderColor;

  PostImageInfo({this.url, this.size, this.placeholderColor});

  factory PostImageInfo.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final url = data['url'] as String;
    final width = data['width'] as double;
    final height = data['height'] as double;
    final placeholderColor = Color(data['placeholderColor'] as int);
    return PostImageInfo(
        url: url,
        size: Size(width, height),
        placeholderColor: placeholderColor);
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'width': size.width,
      'height': size.height,
      'placeholderColor': placeholderColor.value,
    };
  }
}

class Post {
  final ChaiUser userInfo;
  final String postText;
  final PostImageInfo imageInfo;
  final DateTime timestamp;
  final String id;
  final int likesCount;
  final List<String> likedByIds;
  List<String> showForIds;

  Post(
      {this.id,
      this.userInfo,
      this.postText,
      this.imageInfo,
      this.timestamp,
      this.likesCount,
      this.likedByIds,
      this.showForIds});

  factory Post.fromMap(
      Map<String, dynamic> data, String postId) {
    if (data == null) {
      return null;
    }
    final userInfo = ChaiUser.fromPostMap(data['userInfo']);
    final postText = data['postText'] as String;
    final imageInfo = PostImageInfo.fromMap(data['imageInfo']);
    final timestamp = data['timestamp'] as int;
    final likesCount = data['likesCount'] as int ?? 0;
    final likedByIds = List<String>.from(data['likedByIds'] ?? List.empty());
    final showForIds = List<String>.from(data['showForIds'] ?? List.empty());
    return Post(
        id: postId,
        userInfo: userInfo,
        postText: postText,
        imageInfo: imageInfo,
        timestamp: DateTime.fromMicrosecondsSinceEpoch(timestamp),
        likesCount: likesCount,
        likedByIds: likedByIds,
        showForIds: showForIds);
  }

  Map<String, dynamic> toMap() {
    return {
      'userInfo': userInfo.toMap(basicInfo: true),
      'postText': postText,
      'imageInfo': imageInfo?.toMap(),
      'timestamp': timestamp.microsecondsSinceEpoch,
      'showForIds': showForIds
    };
  }
}
