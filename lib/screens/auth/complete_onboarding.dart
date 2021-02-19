import 'dart:developer';

import 'package:chai/models/chai_user.dart';
import 'package:chai/screens/auth/authenticator.dart';
import 'package:chai/screens/common/theme.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CompleteOnboarding extends StatefulWidget {
  @override
  _CompleteOnboardingState createState() => _CompleteOnboardingState();
}

class _CompleteOnboardingState extends State<CompleteOnboarding> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();
    final user = context.read<User>();

    return StreamBuilder<ChaiUser>(
        stream: firestore.getUser(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            default:
              if (snapshot.hasData) {
                log("Skip onboarding, user exists: " +
                    snapshot.data.toMap().toString());
                context.read<PrefsProvider>().setOnboardingComplete();
                return Authenticator();
              } else {
                return buildOnboarding(context, firestore, user);
              }
          }
        });
  }

  Widget buildOnboarding(
      BuildContext context, FirestoreProvider firestore, User user) {
    final _formKey = GlobalKey<FormState>();

    String username;
    String displayName;

    return Scaffold(
        body: Center(
      child: Container(
        padding: EdgeInsets.all(56),
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Complete your profile",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
            SizedBox(height: 32),
            CircleAvatar(
                backgroundImage: AssetImage("assets/avatar.png"), radius: 56),
            SizedBox(height: 24),
            TextFormField(
                decoration: InputDecoration(hintText: "@username"),
                keyboardType: TextInputType.name,
                validator: (value) => value.length > 2
                    ? null
                    : "Username should be at least 3 characters long",
                onSaved: (value) {
                  username = value;
                }),
            SizedBox(height: 24),
            TextFormField(
                decoration: InputDecoration(hintText: "Full Name"),
                keyboardType: TextInputType.name,
                onSaved: (value) {
                  displayName = value;
                }),
            SizedBox(height: 32),
            TextButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    firestore
                        .setUser(ChaiUser(
                            username: username, displayName: displayName))
                        .then((value) {
                      context.read<PrefsProvider>().setOnboardingComplete();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false);
                    });
                  }
                },
                style: textButtonStyle,
                child: Text("Complete"))
          ]),
        ),
      ),
    ));
  }
}
