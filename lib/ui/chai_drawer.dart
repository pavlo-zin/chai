import 'dart:developer';
import 'dart:io';

import 'package:chai/models/chai_user.dart';
import 'package:chai/providers/auth_provider.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/providers/prefs_provider.dart';
import 'package:chai/screens/user_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'network_avatar.dart';

class ChaiDrawer extends StatelessWidget {
  final AuthProvider auth;

  const ChaiDrawer(this.auth, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: SafeArea(
        child: Drawer(
            elevation: 0,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Header(),
                ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('About',
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  onTap: () => Navigator.of(context).popAndPushNamed("/about"),
                ),
                ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Log out',
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  onTap: () => _showSignOutDialog(context),
                ),
              ],
            )),
      ),
    );
  }

  _handleSignOut(BuildContext context, AuthProvider auth) async {
    await context.read<PrefsProvider>().clear();
    auth.signOut().then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false));
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    const message = 'Are you sure you want to log out of chai?';
    const okText = 'Log out';
    const cancelText = 'Cancel';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
              brightness: MediaQuery.of(context).platformBrightness,
              primarySwatch: Colors.deepOrange),
          child: Platform.isAndroid
              ? AlertDialog(
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                      child: Text(cancelText.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(okText.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => _handleSignOut(context, auth),
                    ),
                  ],
                )
              : CupertinoAlertDialog(
                  content: Text(message),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(cancelText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      child: Text(okText,
                          style: TextStyle(color: Colors.redAccent)),
                      onPressed: () => _handleSignOut(context, auth),
                    )
                  ],
                ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 24, top: 16, bottom: 16),
      child: StreamBuilder<ChaiUser>(
          stream: context.read<FirestoreProvider>().getCurrentUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            final user = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () => _openUserDetails(context, user),
                    child:
                        NetworkAvatar(radius: 36, url: snapshot.data.picUrl)),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openUserDetails(context, user),
                  child: Text(user.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.w800)),
                ),
                GestureDetector(
                  onTap: () => _openUserDetails(context, user),
                  child: Text("@" + user.username,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Theme.of(context).hintColor)),
                ),
                SizedBox(height: 16),
                FollowingInfo(context: context, user: user, fontSize: 16),
                SizedBox(height: 8),
              ],
            );
          }),
    );
  }

  _openUserDetails(BuildContext context, ChaiUser user) {
    Navigator.popAndPushNamed(context, '/user_details',
        arguments: UserDetailsArgs(userIsKnown: true, user: user));
  }
}
