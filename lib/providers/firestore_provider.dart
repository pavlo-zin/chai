import 'dart:developer';
import 'dart:io';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:stream_transform/stream_transform.dart';
import 'package:tuple/tuple.dart';

class FirestoreProvider {
  final String currentUid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  FirestoreProvider({this.currentUid});

  Future<void> setUser(ChaiUser user) async {
    log("setUser $currentUid");

    bool usernameExists = await firestore
        .collection('users')
        .where('username', isEqualTo: user.username)
        .get()
        .then((value) => value.docs.isNotEmpty);

    if (usernameExists) {
      log("Error: username ${user.username} already exists");
      return Future.error(UsernameExistsError());
    }

    var users = firestore.collection('users');
    return users.doc(currentUid).set(user.toMap());
  }

  Stream<ChaiUser> getUser() {
    log("getUser $currentUid");
    return firestore
        .collection('users')
        .doc(currentUid)
        .snapshots()
        .map((doc) => ChaiUser.fromMap(doc.data(), doc.id));
  }

  Future<void> followUser(ChaiUser toFollow, ChaiUser current) async {
    log("followUser: ${toFollow.displayName}, current: ${current.displayName}");

    WriteBatch batch = firestore.batch();

    batch.set(
        firestore
            .collection('users')
            .doc(currentUid)
            .collection('following')
            .doc(toFollow.id),
        toFollow.toMap());

    batch.set(
        firestore
            .collection('users')
            .doc(toFollow.id)
            .collection('followers')
            .doc(current.id),
        current.toMap());

    return batch.commit();
  }

  Future<void> unfollowUser(ChaiUser toUnfollow, ChaiUser current) async {
    log("unfollowUser: ${toUnfollow.displayName}, current: ${current.displayName}");

    WriteBatch batch = firestore.batch();

    batch.delete(firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(toUnfollow.id));

    batch.delete(firestore
        .collection('users')
        .doc(toUnfollow.id)
        .collection('followers')
        .doc(current.id));

    firestore
        .collection('users')
        .doc(currentUid)
        .collection('posts')
        .where('userInfo.id', isEqualTo: toUnfollow.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
  }

  Stream<Tuple2> checkIfFollowing(ChaiUser user) {
    log("checkIfFollowing");

    final check = firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(user.id)
        .snapshots()
        .map((doc) => ChaiUser.fromMap(doc.data(), doc.id));

    return getUser().combineLatest(check,
        (currentUser, followedUser) => Tuple2(currentUser, followedUser));
  }

  Future<void> submitPost(Post post) async {
    WriteBatch batch = firestore.batch();

    firestore
        .collection('users')
        .doc(currentUid)
        .collection('followers')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.set(
            firestore
                .collection('users')
                .doc(document.id)
                .collection('posts')
                .doc(),
            post.toMap());
      });

      batch.set(
          firestore
              .collection('users')
              .doc(currentUid)
              .collection('posts')
              .doc(),
          post.toMap());

      return batch.commit();
    });
  }

  Stream<List<Post>> getPosts({String uid, bool onlyForThisUser = false}) {
    final String userId = uid == null ? currentUid : uid;

    log("getPosts for user: $userId");

    var postsQuery = firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .orderBy('timestamp', descending: true);

    if (onlyForThisUser)
      postsQuery = postsQuery.where('userInfo.id', isEqualTo: userId);

    return postsQuery.snapshots().map((snapshot) => snapshot.docs
        .map((document) => Post.fromMap(document.data(), document.id, userId))
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

  Future<String> uploadAvatar(String uid, File file) async {
    log("uploadAvatar");
    try {
      firebase_storage.TaskSnapshot storageTaskSnapshot =
          await storage.ref('uploads/avatars/$uid/avatar.jpg').putFile(file);
      print(storageTaskSnapshot.ref.getDownloadURL());
      log("uploadAvatar file is put");

      var url = await storageTaskSnapshot.ref.getDownloadURL();
      log("uploadAvatar url $url");

      return url;
    } catch (e) {
      log(e);
      return Future.error(e);
    }
  }

  bool isUserMe(ChaiUser user) => user.id == currentUid;
}

class UsernameExistsError {}
