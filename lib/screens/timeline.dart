import 'dart:developer';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/screens/auth/auth_provider.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:chai/ui/emoji_text.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'compose_post.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    log("initState");

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("AppLifecycleState changed to: $state");
    if (state == AppLifecycleState.resumed) {
      setState(() {}); // refresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final firestore = context.read<FirestoreProvider>();

    return Scaffold(
      drawer: _buildDrawer(firestore, context, authProvider),
      body: StreamBuilder<List<Post>>(
          stream: firestore.getPosts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return Center(
                child: Text("What? No posts yet?",
                    style: Theme.of(context).textTheme.headline5),
              );
            }
            return SafeArea(
              child: CustomScrollView(slivers: [
                SliverAppBar(
                  floating: true,
                  title: SizedBox(
                      height: 28,
                      child: Image(image: AssetImage("assets/logo.png"))),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.search),
                        color: Colors.black87,
                        onPressed: () {
                          Navigator.of(context).pushNamed("/search");
                        })
                  ],
                ),
                CupertinoSliverRefreshControl(
                  onRefresh: () {
                    setState(() {});
                    return Future.delayed(Duration(milliseconds: 900));
                  },
                ),
                SliverList(
                    delegate:
                        SliverChildListDelegate(buildPostTiles(snapshot.data)))
              ]),
            );
          }),
      floatingActionButton: _buildFab(context),
    );
  }

  _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => {
        Navigator.push(
            context,
            PageTransition(
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 200),
                type: PageTransitionType.bottomToTop,
                child: ComposePost(),
                curve: Curves.fastOutSlowIn))
      },
      child: Icon(Icons.post_add),
    );
  }

  buildPostTiles(List<Post> posts) {
    return posts
        .map((post) => Column(
              children: [
                ListTile(
                    onTap: () {},
                    leading: NetworkAvatar(url: post.userInfo.picUrl),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text(post.userInfo.displayName,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text("·",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold)),
                          ),
                          Text(_humanizeTime(post.timestamp),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: Colors.black54)),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: EmojiText(
                              text: post.postText,
                              style: Theme.of(context).textTheme.subtitle1),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPostIcon(
                                Icons.mode_comment_outlined, "13", () {}),
                            _buildPostIcon(Icons.favorite_outline, "69", () {}),
                            _buildPostIcon(Icons.ios_share, "", () {}),
                            SizedBox(width: 32)
                          ],
                        ),
                        SizedBox(height: 8)
                      ],
                    )),
                Divider(height: 1)
              ],
            ))
        .toList();
  }

  _buildPostIcon(IconData icon, String text, VoidCallback onPressed) {
    return Row(children: [
      IconButton(
        icon: Icon(icon, color: Colors.black54),
        onPressed: onPressed,
        iconSize: 18,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
      ),
      SizedBox(width: 4),
      Text(text, style: Theme.of(context).textTheme.caption)
    ]);
  }

  _buildDrawer(FirestoreProvider firestore, BuildContext context,
      AuthProvider authProvider) {
    return Drawer(
        child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildDrawerHeader(firestore),
        ListTile(
          title: Text('About'),
          onTap: () {
            Navigator.of(context).pushNamed("/about");
          },
        ),
        ListTile(
          title: Text('Sign out'),
          onTap: () => _handleSignOut(context, authProvider),
        ),
      ],
    ));
  }

  _buildDrawerHeader(FirestoreProvider firestore) {
    return Container(
      height: 240,
      child: DrawerHeader(
        child: StreamBuilder<ChaiUser>(
            stream: firestore.getUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(snapshot.data.picUrl)),
                    SizedBox(
                      height: 16,
                    ),
                    Text(snapshot.data.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text("@" + snapshot.data.username,
                        style: Theme.of(context).textTheme.subtitle1),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                );
              else
                return Container();
            }),
      ),
    );
  }

  _handleSignOut(BuildContext context, AuthProvider authProvider) {
    context.read<PrefsProvider>().clear();
    authProvider.signOut().then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false));
  }

  // todo refactor this
  // todo also display actual date after some long time (eg. after 12h)
  _humanizeTime(DateTime time) {
    return timeago
        .format(time, locale: 'en_short')
        .replaceAll(RegExp("~"), '')
        .replaceAll(RegExp("min"), 'm')
        .replaceAll(RegExp(" "), '');
  }
}
