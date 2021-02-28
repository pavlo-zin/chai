import 'dart:async';
import 'dart:developer';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/screens/auth/auth_provider.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:chai/ui/chai_drawer.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:chai/ui/timeline_empty_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flash/flash.dart';
import 'package:tuple/tuple.dart';

import 'compose_post.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> with WidgetsBindingObserver {
  StreamController<bool> refreshTimeController = StreamController.broadcast();
  Stream<List<Post>> postsStream;
  Stream<ChaiUser> user;
  AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    user = context.read<FirestoreProvider>().getUser();
    postsStream = context.read<FirestoreProvider>().getPosts();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    refreshTimeController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("AppLifecycleState changed to: $state");
    if (state == AppLifecycleState.resumed) {
      refreshTimeController.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    log("build timeline");

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Theme.of(context).canvasColor,
        child: Scaffold(
          drawer: ChaiDrawer(authProvider),
          body: StreamBuilder<List<Post>>(
              stream: postsStream,
              builder: (context, snapshot) {
                return SafeArea(
                  bottom: false,
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
                    _buildTimelineView(snapshot)
                  ]),
                );
              }),
          floatingActionButton: _buildFab(context, user),
        ),
      ),
    );
  }

  _buildTimelineView(AsyncSnapshot<List<Post>> snapshot) {
    if (snapshot.hasError) {
      return SliverFillRemaining(
        child: Center(
            child: Text(
                "Something wrong... Please try again later ${snapshot.error}",
                style: Theme.of(context).textTheme.headline6)),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()));
    }

    if (snapshot.connectionState == ConnectionState.active) {
      return snapshot.data.isEmpty
          ? TimelineEmptyView(context: context)
          : SliverPadding(
              padding: const EdgeInsets.only(bottom: 112.0),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return buildPostTile(snapshot.data[index], index);
                },
                childCount: snapshot.hasData ? snapshot.data.length : 0,
              )),
            );
    }
  }

  _buildFab(BuildContext context, Stream<ChaiUser> userStream) {
    return StreamBuilder(
        stream: userStream,
        builder: (context, snapshot) {
          log("_buildFab User ${snapshot.data}");

          return snapshot.hasData
              ? FloatingActionButton(
                  onPressed: () => _composePostAndWaitForResult(snapshot.data),
                  child: Icon(Icons.post_add),
                )
              : SizedBox.shrink();
        });
  }

  _composePostAndWaitForResult(ChaiUser user) async {
    final result = await Navigator.push(
        context,
        PageTransition(
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 200),
            type: PageTransitionType.bottomToTop,
            child: ComposePost(),
            settings: RouteSettings(arguments: user),
            curve: Curves.fastOutSlowIn));
    if (result != null) showSentSuccess();
  }

  buildPostTile(Post post, int index) {
    return Column(
      children: [
        ListTile(
            onTap: () {
              log("Post id ${post.id}, info: ${post.userInfo.toMap(includeUid: true)}");
            },
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/user_details',
                      arguments:
                          Tuple2(post.userInfo, "timelineProfilePic$index"));
                },
                child: Hero(
                    tag: 'timelineProfilePic$index',
                    child: NetworkAvatar(url: post.userInfo.picUrl))),
            title: Transform.translate(
              offset: Offset(-8, 0),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 0,
                      child: Text(post.userInfo.displayName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          "@${post.userInfo.username}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Theme.of(context).hintColor),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text("·",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.w500)),
                      ),
                    ),
                    StreamBuilder<Object>(
                        stream: refreshTimeController.stream,
                        builder: (context, snapshot) {
                          return Expanded(
                            flex: 0,
                            child: Text(_humanizeTime(post.timestamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                        color: Theme.of(context).hintColor)),
                          );
                        }),
                  ],
                ),
              ),
            ),
            subtitle: Transform.translate(
              offset: Offset(-8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(post.postText,
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPostIcon(Icons.mode_comment_outlined, "13", () {},
                          padding:
                              EdgeInsets.only(top: 8, right: 12, bottom: 8)),
                      _buildPostIcon(Icons.favorite_outline, "69", () {}),
                      _buildPostIcon(Icons.ios_share, "", () {}),
                    ],
                  )
                ],
              ),
            )),
        Divider(height: 0)
      ],
    );
  }

  _buildPostIcon(IconData icon, String text, VoidCallback onPressed,
      {EdgeInsets padding}) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      constraints: BoxConstraints(minHeight: 0, minWidth: 0),
      padding: padding == null
          ? EdgeInsets.only(top: 8, right: 12, bottom: 8, left: 12)
          : padding,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        child: Row(children: [
          Icon(icon, size: 18),
          SizedBox(width: 4),
          Text(text, style: Theme.of(context).textTheme.caption)
        ]),
      ),
    );
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

  void showSentSuccess() {
    showFlash(
      context: context,
      duration: const Duration(seconds: 4),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          margin: EdgeInsets.symmetric(horizontal: 16),
          controller: controller,
          backgroundColor: Theme.of(context).primaryColorLight,
          brightness: Brightness.light,
          boxShadows: [
            BoxShadow(blurRadius: 3, color: Theme.of(context).primaryColorDark)
          ],
          borderRadius: BorderRadius.circular(10),
          style: FlashStyle.floating,
          position: FlashPosition.top,
          child: FlashBar(
            message: Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).accentColor),
                SizedBox(width: 8),
                Text('Your post was sent!'),
              ],
            ),
          ),
        );
      },
    );
  }
}