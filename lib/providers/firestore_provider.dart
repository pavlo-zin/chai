import 'dart:developer';
import 'dart:io';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:nanoid/nanoid.dart';

class FirestoreProvider {
  final String currentUid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  FirestoreProvider({this.currentUid});

  Future<void> createUser(ChaiUser user) async {
    log("createUser $currentUid");

    bool usernameExists = await firestore
        .collection('users')
        .where('username', isEqualTo: user.username)
        .get()
        .then((value) => value.docs.isNotEmpty);

    if (usernameExists) {
      log("Error: username ${user.username} already exists");
      return Future.error(UsernameExistsError());
    }

    return firestore.collection('users').doc(currentUid).set(user.toMap());
  }

  Stream<ChaiUser> getCurrentUser() => getUserById(currentUid);

  Stream<ChaiUser> getUserById(String uid) => firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => ChaiUser.fromMap(snapshot.data(), snapshot.id));

  Stream<ChaiUser> getUserByUsername(String username) => firestore
      .collection('users')
      .where('_searchUsername',
          isEqualTo: username.toLowerCase().replaceAll('@', ''))
      .snapshots()
      .map((snapshot) => ChaiUser.fromMap(
          snapshot.docs.single.data(), snapshot.docs.single.id));

  Future<void> toggleUserFollow(ChaiUser toFollow, bool isFollowing) async {
    WriteBatch batch = firestore.batch();

    batch.update(firestore.collection('users').doc(toFollow.id), {
      'followedByIds': isFollowing
          ? FieldValue.arrayRemove([currentUid])
          : FieldValue.arrayUnion([currentUid]),
      'followersCount': FieldValue.increment(isFollowing ? -1 : 1)
    });

    batch.update(firestore.collection('users').doc(currentUid),
        {'followingCount': FieldValue.increment(isFollowing ? -1 : 1)});

    return batch.commit();
  }

  Future<bool> togglePostLike(Post post) async {
    return firestore.runTransaction((transaction) async {
      var latestPost = await transaction
          .get(firestore.collection('posts').doc(post.id))
          .then((value) => Post.fromMap(value.data(), value.id));

      final isLikedByMe = latestPost.likedByIds.contains(currentUid);

      transaction.update(firestore.collection('posts').doc(latestPost.id), {
        'likesCount': latestPost.likesCount + (isLikedByMe ? -1 : 1),
        'likedByIds': isLikedByMe
            ? (latestPost.likedByIds..remove(currentUid))
            : (latestPost.likedByIds..add(currentUid))
      });

      return !isLikedByMe;
    });
  }

  bool isLikedByMe(Post post) => post.likedByIds.contains(currentUid);

  Future<void> submitPost(Post post) async =>
      firestore.collection('posts').doc(nanoid(10)).set(post.toMap());

  Stream<List<Post>> getFeed() {
    var postsQuery = firestore
        .collection('posts')
        .where('showForIds', arrayContains: currentUid)
        .limit(50)
        .orderBy('timestamp', descending: true);

    return postsQuery.snapshots().map((snapshot) => snapshot.docs
        .map((document) => Post.fromMap(document.data(), document.id))
        .toList());
  }

  Stream<List<Post>> getPostsFromUser({String uid}) {
    var postsQuery = firestore
        .collection('posts')
        .where('userInfo.id', isEqualTo: uid)
        .limit(50)
        .orderBy('timestamp', descending: true);

    return postsQuery.snapshots().map((snapshot) => snapshot.docs
        .map((document) => Post.fromMap(document.data(), document.id))
        .toList());
  }

  Future<List<ChaiUser>> searchUsers(String query) async {
    if (query.isEmpty) return List.empty();

    final searchQuery = query.toLowerCase();

    Future<List<ChaiUser>> searchByUsername = firestore
        .collection('users')
        .where('_searchUsername', isGreaterThanOrEqualTo: searchQuery)
        .where('_searchUsername', isLessThan: searchQuery + 'z')
        .get()
        .then((value) => value.docs
            .map((document) => ChaiUser.fromMap(document.data(), document.id))
            .toList());

    Future<List<ChaiUser>> searchByDisplayName = firestore
        .collection('users')
        .where('_searchDisplayName', isGreaterThanOrEqualTo: searchQuery)
        .where('_searchDisplayName', isLessThan: searchQuery + 'z')
        .get()
        .then((value) => value.docs
            .map((document) => ChaiUser.fromMap(document.data(), document.id))
            .toList());

    return Future.wait([searchByUsername, searchByDisplayName]).then((value) =>
        value.expand((element) => element).toList().toSet().toList());
  }

  Future<String> uploadAvatar(File file) async {
    final uploadPath = 'uploads/avatars/$currentUid/avatar.jpg';
    return _uploadImage(file, uploadPath);
  }

  Future<String> uploadPostImage(File file) async {
    final fileName = '${DateTime.now().toIso8601String()}.jpg';
    final uploadPath = 'uploads/postPics/$currentUid/$fileName';
    return _uploadImage(file, uploadPath);
  }

  Future<String> _uploadImage(File file, String uploadPath) async {
    try {
      final uploadTask = await storage.ref(uploadPath).putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      log(e);
      return Future.error(e);
    }
  }

  bool isUserMe(ChaiUser user) => user.id == currentUid;
}

class UsernameExistsError {}
