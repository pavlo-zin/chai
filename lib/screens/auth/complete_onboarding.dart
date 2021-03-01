import 'dart:developer';
import 'dart:io';

import 'package:chai/models/chai_user.dart';
import 'package:chai/screens/auth/authenticator.dart';
import 'package:chai/common/theme.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CompleteOnboarding extends StatefulWidget {
  @override
  _CompleteOnboardingState createState() => _CompleteOnboardingState();
}

class _CompleteOnboardingState extends State<CompleteOnboarding> {
  final _usernameText = TextEditingController();
  bool _usernameTaken = false;
  String _avatarImageUrl;
  final picker = ImagePicker();
  AsyncSnapshot<User> userSnapshot;

  @override
  void initState() {
    super.initState();
    userSnapshot = context.read<AsyncSnapshot<User>>();
  }

  @override
  void dispose() {
    _usernameText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();

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
                return buildOnboarding(context, firestore, userSnapshot.data);
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
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(56),
          child: Form(
            key: _formKey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Create your profile",
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 24),
              SizedBox(
                height: 112,
                width: 112,
                child: RawMaterialButton(
                  onPressed: () {
                    getImage().then((value) {
                      firestore.uploadAvatar(user.uid, File(value.path)).then(
                          (value) {
                        log("avatar url $value");
                        setState(() {
                          _avatarImageUrl = value;
                        });
                      }, onError: (e) {
                        log("avatar error $e");
                      });
                    });
                  },
                  elevation: 0,
                  highlightElevation: 0,
                  highlightColor: Colors.deepOrange[100],
                  splashColor: Colors.transparent,
                  fillColor: Colors.deepOrange[50],
                  child: _avatarImageUrl == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 36,
                          color: Colors.deepOrange,
                        )
                      : NetworkAvatar(
                          url: _avatarImageUrl,
                          radius: 56,
                        ),
                  shape: CircleBorder(),
                ),
              ),
              SizedBox(height: 24),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Full name",
                    style: Theme.of(context).textTheme.caption,
                  )),
              TextFormField(
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                      hintText: "Name",
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).disabledColor),
                      )),
                  keyboardType: TextInputType.name,
                  validator: (value) =>
                      value.length > 2 ? null : "Name can't be empty",
                  onSaved: (value) {
                    displayName = value;
                  }),
              SizedBox(height: 24),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "What should people call you? Username is unique and can be changed later",
                    style: Theme.of(context).textTheme.caption,
                  )),
              TextFormField(
                  autocorrect: false,
                  enableSuggestions: false,
                  controller: _usernameText,
                  decoration: InputDecoration(
                      hintText: "Username",
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).disabledColor),
                      ),
                      errorText:
                          _usernameTaken ? "Username already taken" : null),
                  keyboardType: TextInputType.name,
                  validator: (value) => value.length > 2
                      ? null
                      : "Username must be at least 3 characters long",
                  onSaved: (value) {
                    username = value;
                  }),
              SizedBox(height: 24),
              TextButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      final user = ChaiUser(
                          username: username,
                          displayName: displayName,
                          picUrl: _avatarImageUrl);
                      firestore.setUser(user).then((value) {
                        log("User saved");
                      }, onError: (error) {
                        if (error is UsernameExistsError) {
                          setState(() {
                            _usernameTaken = true;
                          });
                        }
                      });
                    }
                  },
                  style: textButtonStyle,
                  child: Text("Save"))
            ]),
          ),
        ),
      ),
    ));
  }

  Future<PickedFile> getImage() async {
    return await picker.getImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 69);
  }
}
