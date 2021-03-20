import 'dart:async';
import 'dart:io';

import 'package:chai/common/file_utils.dart';
import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/providers/auth_provider.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/screens/search.dart';
import 'package:chai/screens/user_details.dart';
import 'package:chai/ui/chai_drawer.dart';
import 'package:chai/ui/timeline_empty_view.dart';
import 'package:chai/ui/timeline_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flash/flash.dart';

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
  ValueNotifier<bool> _isLoading = ValueNotifier(false);

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
    if (state == AppLifecycleState.resumed) {
      refreshTimeController.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChaiDrawer(authProvider),
            VerticalDivider(),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: StreamBuilder<List<Post>>(
                  stream: postsStream,
                  builder: (context, snapshot) {
                    return CustomScrollView(slivers: [
                      _buildAppBar(context),
                      _buildTimelineView(snapshot)
                    ]);
                  }),
            ),
            VerticalDivider(),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24.0),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 6,
                  child: Search()),
            )
          ],
        ),
        floatingActionButton: _buildFab(context, user),
      );
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            drawer: ChaiDrawer(authProvider),
            body: StreamBuilder<List<Post>>(
                stream: postsStream,
                builder: (context, snapshot) {
                  return CustomScrollView(slivers: [
                    _buildAppBar(context),
                    _buildTimelineView(snapshot)
                  ]);
                }),
            floatingActionButton: _buildFab(context, user),
          ),
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      centerTitle: true,
      bottom: PreferredSize(
          preferredSize: Size(double.infinity, 4.0),
          child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) => Visibility(
              visible: isLoading,
              child: SizedBox(height: 4.0, child: LinearProgressIndicator()),
            ),
          )),
      title: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              height: 28,
              child: Image(
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  colorBlendMode: BlendMode.modulate,
                  image: AssetImage(MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? "assets/logo.png"
                      : "assets/logo-white.png"))),
        ],
      ),
      leading: kIsWeb
          ? null
          : IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Feather.menu)),
      actions: kIsWeb
          ? null
          : [
              IconButton(
                  icon: Icon(Feather.search),
                  onPressed: () => Navigator.of(context).pushNamed("/search"))
            ],
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
                  final post = snapshot.data[index];
                  return TimelineListTile(
                      context: context,
                      refreshTimeStream: refreshTimeController.stream,
                      post: snapshot.data[index],
                      index: index,
                      onProfilePicTap: () => _openUserDetails(post, index));
                },
                childCount: snapshot.hasData ? snapshot.data.length : 0,
              )),
            );
    }
  }

  _buildFab(BuildContext context, Stream<ChaiUser> userStream) {
    final fabPadding = kIsWeb ? MediaQuery.of(context).size.width / 4 : 0.0;
    return StreamBuilder(
        stream: userStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Padding(
                padding: EdgeInsets.only(right: fabPadding),
                child: FloatingActionButton(
                    elevation: 2,
                    highlightElevation: 2,
                    splashColor: Colors.transparent,
                    onPressed: () => _composePost(snapshot.data),
                    child: Icon(Feather.feather, size: 26),
                  ),
              )
              : SizedBox.shrink();
        });
  }

  _composePost(ChaiUser user) async {
    final result = await Navigator.push(
        context,
        PageTransition(
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 200),
            type: PageTransitionType.bottomToTop,
            child: ComposePost(),
            settings: RouteSettings(arguments: user),
            curve: Curves.fastOutSlowIn));

    await _handleComposePostResult(user, result);
  }

  _handleComposePostResult(ChaiUser user, ComposePostResult result) async {
    if (result == null) return;
    
    final firestore = context.read<FirestoreProvider>();
    var post;

    _isLoading.value = true;
    
    if (result.imagePath != null) {
      final imageFile = File(result.imagePath);

      final color = await FileUtils.getImagePalette(imageFile);
      final size = await FileUtils.getImageSize(imageFile);

      final imageUrl = await firestore.uploadPostImage(imageFile);
      post = Post(
          userInfo: user,
          postText: result.text,
          imageInfo:
              PostImageInfo(url: imageUrl, size: size, placeholderColor: color),
          timestamp: DateTime.now());
    } else {
      post = Post(
          userInfo: user, postText: result.text, timestamp: DateTime.now());
    }

    await firestore.submitPost(post);
    _isLoading.value = false;
    _showSentSuccess();
  }

  _showSentSuccess() {
    showFlash(
      context: context,
      duration: const Duration(seconds: 4),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          margin: EdgeInsets.only(left: 16, right: 16, top: 12),
          controller: controller,
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Theme.of(context).primaryColorLight
                  : Colors.deepOrange[900],
          brightness: MediaQuery.of(context).platformBrightness,
          borderColor: Theme.of(context).primaryColor.withOpacity(0.3),
          boxShadows: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 3,
                color: Theme.of(context).hintColor.withOpacity(0.2))
          ],
          borderRadius: BorderRadius.circular(10),
          style: FlashStyle.floating,
          position: FlashPosition.top,
          child: FlashBar(
            message: Row(
              children: [
                Icon(Feather.check_circle,
                    color: Theme.of(context).accentColor),
                SizedBox(width: 8),
                Text('Your post was sent!'),
              ],
            ),
          ),
        );
      },
    );
  }

  _openUserDetails(Post post, int index) {
    Navigator.pushNamed(context, '/user_details',
        arguments: UserDetailsArgs(
            userIsKnown: true,
            user: post.userInfo,
            profilePicHeroTag: "timelineProfilePic$index"));
  }
}
