import 'dart:developer';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  final String uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirestoreProvider({this.uid});

  Future<void> setUser(ChaiUser user) {
    log("setUser $uid");
    var users = firestore.collection('users');
    return users.doc(uid).set(user.toMap());
  }

  Stream<ChaiUser> getUser() {
    log("getUser $uid");
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => ChaiUser.fromMap(event.data()));
  }

  Future<void> submitPost(Post post) async {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc()
        .set(post.toMap());
  }

  Stream<List<Post>> getPosts() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((document) => Post.fromMap(document.data()))
            .toList());
  }

  Future<List<ChaiUser>> searchUsers(String query) async {
    if (query.isEmpty) return null;

    Future<List<ChaiUser>> searchByUsername = firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .get()
        .then((value) => value.docs
            .map((document) => ChaiUser.fromMap(document.data()))
            .toList());

    Future<List<ChaiUser>> searchByDisplayName = firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: query + 'z')
        .get()
        .then((value) => value.docs
            .map((document) => ChaiUser.fromMap(document.data()))
            .toList());

    return Future.wait([searchByUsername, searchByDisplayName]).then((value) =>
        value.expand((element) => element).toList().toSet().toList());
  }
}
