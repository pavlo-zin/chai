import 'dart:developer';

import 'package:chai/providers/prefs_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider {
  Future<void> verifyPhoneNumber(String phone,
      {PhoneVerificationFailed error, PhoneCodeSent codeSent}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        // todo android only
      },
      verificationFailed: error,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {
        // todo android only
      },
    );
  }

  Future<void> signInWithPhone(String code, PrefsProvider prefs) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: prefs.getVerificationId(), smsCode: code);

    await FirebaseAuth.instance
        .signInWithCredential(phoneAuthCredential)
        .catchError((e) => log("signInWithPhone error ${e.toString()}"));
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}