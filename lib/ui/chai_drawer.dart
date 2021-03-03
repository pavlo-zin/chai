import 'dart:developer';

import 'package:chai/models/chai_user.dart';
import 'package:chai/screens/auth/auth_provider.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'network_avatar.dart';

class ChaiDrawer extends StatelessWidget {
  final AuthProvider auth;

  const ChaiDrawer(this.auth, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 0,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 8),
              height: 240,
              child: DrawerHeader(
                child: StreamBuilder<ChaiUser>(
                    stream: context.read<FirestoreProvider>().getUser(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        log("_buildDrawerHeader User ${snapshot.data.id}");
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NetworkAvatar(
                                radius: 36, url: snapshot.data.picUrl),
                            SizedBox(
                              height: 16,
                            ),
                            Text(snapshot.data.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(fontWeight: FontWeight.bold)),
                            Text("@" + snapshot.data.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                        color: Theme.of(context).hintColor)),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        );
                      } else {
                        log("_buildDrawerHeader User ${snapshot.data}");

                        return Container();
                      }
                    }),
              ),
            ),
            ListTile(
              title: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('About'),
              ),
              onTap: () {
                Navigator.of(context).pushNamed("/about");
              },
            ),
            ListTile(
              title: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Sign out'),
              ),
              onTap: () => _handleSignOut(context, auth),
            ),
          ],
        ));
  }

  _handleSignOut(BuildContext context, AuthProvider auth) async {
    await context.read<PrefsProvider>().clear();
    auth.signOut().then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false));
  }
}
