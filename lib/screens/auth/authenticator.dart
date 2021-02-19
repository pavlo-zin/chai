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
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();
    final onboardingComplete =
        context.read<PrefsProvider>().isOnboardingComplete();

    log("AuthenticatorState onboardingComplete: ${onboardingComplete.toString()}, user: ${user.toString()}");

    if (user == null) return Welcome();
    if (user != null && !onboardingComplete) return CompleteOnboarding();
    return Timeline();
  }
}
