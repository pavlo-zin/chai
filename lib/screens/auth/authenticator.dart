import 'dart:developer';

import 'package:chai/screens/auth/welcome.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../timeline.dart';
import 'complete_onboarding.dart';

class Authenticator extends StatefulWidget {
  @override
  _AuthenticatorState createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  bool onboardingComplete;

  @override
  void initState() {
    super.initState();
    onboardingComplete = context.read<PrefsProvider>().isOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    log("AuthenticatorState build");

    AsyncSnapshot<User> userSnapshot = context.watch<AsyncSnapshot<User>>();

    switch (userSnapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      case ConnectionState.active:
        final user = userSnapshot.data;
        if (user == null) return Welcome();
        if (user != null && !onboardingComplete) return CompleteOnboarding();
        return Timeline();
      default:
        return SizedBox.shrink();
    }
  }
}
