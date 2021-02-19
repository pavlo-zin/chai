import 'dart:developer';

import 'package:chai/screens/prefs_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthResult authResult;

  Future<void> createAccount(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      log("createAccount success");
      _sendEmailVerification();
      authResult = AuthResult.SUCCESS;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log("weak-password");
        authResult = AuthResult.WEEK_PASSWORD;
      } else if (e.code == 'email-already-in-use') {
        log("email-already-in-use");
        authResult = AuthResult.EMAIL_EXISTS;
      } else {
        log("UNKNOWN_ERROR");
        authResult = AuthResult.UNKNOWN_ERROR;
      }
    } catch (e) {
      log("UNKNOWN_ERROR");
      authResult = AuthResult.UNKNOWN_ERROR;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      authResult = AuthResult.SUCCESS;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log("user-not-found");

        authResult = AuthResult.USER_NOT_FOUND;
      } else if (e.code == 'wrong-password') {
        log("wrong-password");

        authResult = AuthResult.WRONG_PASSWORD;
      } else {
        log("UNKNOWN_ERROR");

        authResult = AuthResult.UNKNOWN_ERROR;
      }
    }
    notifyListeners();
  }

  Future<void> verifyPhoneNumber(String phone,
      {PhoneVerificationFailed error, PhoneCodeSent codeSent}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        // android only
      },
      verificationFailed: error,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {
        // android only
      },
    );
  }

  Future<void> signInWithPhone(String code, PrefsProvider prefs) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: prefs.getVerificationId(), smsCode: code);

    await FirebaseAuth.instance
        .signInWithCredential(phoneAuthCredential)
        .catchError((e) => log("signInWithPhone error" + e));
  }

  Future<void> _sendEmailVerification() async {
    log("sendEmailVerification");

    User user = FirebaseAuth.instance.currentUser;
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      log("sendEmailVerification +");
    }
  }

  Future<void> reloadUser() async {
    log("reloadUser");

    User user = FirebaseAuth.instance.currentUser;
    await user.reload();
    log("reloadUser: " + user.emailVerified.toString());
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

enum AuthResult {
  SUCCESS,
  USER_NOT_FOUND,
  WEEK_PASSWORD,
  WRONG_PASSWORD,
  EMAIL_EXISTS,
  UNKNOWN_ERROR
}
