import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:chai/ui/timeline_list_tile.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class UserDetailsArgs {
  final bool userIsKnown;
  final ChaiUser user;
  final String profilePicHeroTag;
  final String username;

  UserDetailsArgs(
      {@required this.userIsKnown,
      this.user,
      this.profilePicHeroTag,
      this.username});
}

class UserDetails extends StatefulWidget {
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  ScrollController _controller;
  ValueNotifier<double> _offset = ValueNotifier(0);

  _scrollListener() {
    log("offset: ${_controller.offset}");
    _offset.value = _controller.offset;
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _offset.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();
    final args = ModalRoute.of(context).settings.arguments as UserDetailsArgs;

    log("user_details build");

    return args.userIsKnown
        ? _buildUserDetailsView(args, firestore)
        : FutureBuilder<ChaiUser>(
            future: firestore.getUserByUsername(args.username),
            builder: (context, snapshot) {
              log("connectionState ${snapshot.connectionState}");

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildPlaceholderView(args.username);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.hasData
                    ? _buildUserDetailsView(
                        UserDetailsArgs(
                            userIsKnown: false,
                            user: snapshot.data,
                            profilePicHeroTag: ''),
                        firestore)
                    : _buildPlaceholderView(args.username, isLoading: false);
              }
              return SizedBox.shrink();
            });
  }

  _buildPlaceholderView(String username, {bool isLoading = true}) {
    return Scaffold(
        body: NestedScrollView(
            body: isLoading
                ? SizedBox.shrink()
                : _buildUserNotFoundView(username),
            controller: _controller,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      color: Colors.deepOrange[200],
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 60,
                            color: Theme.of(context).canvasColor,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16, bottom: 10),
                            child: NetworkAvatar(
                              drawBorder: true,
                              radius: 40,
                              useColorAsPlaceholder: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  expandedHeight: 150,
                ),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    isLoading ? '' : username,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ))
              ];
            }));
  }

  _buildUserDetailsView(UserDetailsArgs args, FirestoreProvider firestore) {
    log("_buildUserDetailsView");
    final ChaiUser user = args.user;
    final String profilePicTag = args.profilePicHeroTag;
    return Scaffold(
        body: NestedScrollView(
            controller: _controller,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  elevation: 4,
                  title: ValueListenableBuilder(
                      valueListenable: _offset,
                      builder: (context, offset, _) => AnimatedOpacity(
                            opacity: offset > 120 ? 1 : 0,
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              "${user.displayName}",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          )),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      color: Colors.deepOrange[200],
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          SizedBox.expand(
                              child: CachedNetworkImage(
                            imageUrl:
                                'https://source.unsplash.com/9YQGFzg0RiM/1500x1000',
                            fit: BoxFit.cover,
                          )),
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 60,
                            color: Theme.of(context).canvasColor,
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 16, bottom: 4),
                            alignment: Alignment.bottomRight,
                            child: firestore.isUserMe(user)
                                ? buildEditProfileButton(context)
                                : buildFollowButton(context, user, firestore),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16, bottom: 10),
                            child: Hero(
                              tag: profilePicTag,
                              child: ValueListenableBuilder(
                                valueListenable: _offset,
                                builder: (context, offset, _) =>
                                    AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: offset > 30 ? 0 : 1,
                                  curve: Curves.fastOutSlowIn,
                                  child: NetworkAvatar(
                                    drawBorder: true,
                                    radius: offset == 0
                                        ? 40
                                        : offset * 0.5 > 20
                                            ? 20
                                            : 40 - offset * 0.5,
                                    url: user.picUrl,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  expandedHeight: 150,
                  pinned: true,
                  floating: true,
                  snap: true,
                  actions: [
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 100,
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ListView(children: [
                                    ListTile(
                                        leading: CircleAvatar(
                                          child: Icon(
                                            Icons.block,
                                            size: 32,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                          backgroundColor:
                                              Theme.of(context).canvasColor,
                                        ),
                                        title: Text("Block @${user.username}"))
                                  ]),
                                );
                              });
                        },
                        icon: Icon(Icons.more_horiz))
                  ],
                ),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.displayName}",
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "@${user.username}",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Theme.of(context).hintColor),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "There are two kinds of people in the world, and I don't like them both!",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text("69",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                              SizedBox(width: 2),
                              Text("Following",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context).hintColor))
                            ],
                          ),
                          SizedBox(width: 8),
                          Row(
                            children: [
                              Text("983",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                              SizedBox(width: 2),
                              Text("Followers",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context).hintColor))
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ))
              ];
            },
            body: FutureBuilder<ChaiUser>(
                future: Future.delayed(
                    Duration(milliseconds: args.userIsKnown ? 0 : 300)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: null,
                              ))),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildTimeline(firestore, user);
                  }
                  return SizedBox.shrink();
                })));
  }

  _buildTimeline(FirestoreProvider firestore, ChaiUser user) {
    return StreamBuilder<List<Post>>(
        stream: firestore.getPosts(uid: user.id, onlyForThisUser: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active)
            return Column(
              children: [
                Divider(
                  height: 8,
                ),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 0, bottom: 56),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return TimelineListTile(
                            context: context,
                            post: snapshot.data[index],
                            index: index);
                      }),
                ),
              ],
            );
          return SizedBox.shrink();
        });
  }

  buildFollowButton(
      BuildContext context, ChaiUser otherUser, FirestoreProvider firestore) {
    return StreamBuilder<Tuple2>(
        stream: firestore.checkIfFollowing(otherUser),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting)
            return SizedBox.shrink();

          final following = snapshot.data.item2 != null;
          final currentUser = snapshot.data.item1;

          log("following $following");
          return SizedBox(
            width: 100,
            child: RawMaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: following
                        ? BorderSide.none
                        : BorderSide(
                            color: Theme.of(context).primaryColor, width: 2.0)),
                onPressed: () {
                  following
                      ? firestore.unfollowUser(otherUser, currentUser)
                      : firestore.followUser(otherUser, currentUser);
                },
                fillColor: following
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).canvasColor,
                splashColor: Colors.deepOrange[100],
                highlightColor: Colors.deepOrange[200],
                elevation: 0,
                highlightElevation: 0,
                child: Text(
                  following ? "Following" : "Follow",
                  style: TextStyle(
                      color: following
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600),
                )),
          );
        });
  }

  buildEditProfileButton(BuildContext context) {
    return SizedBox(
      width: 100,
      child: RawMaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                  color: Theme.of(context).primaryColor, width: 2.0)),
          onPressed: () {
            showFlash(
                duration: Duration(seconds: 1),
                context: context,
                builder: (_, controller) => Flash(
                    backgroundColor: Theme.of(context).canvasColor,
                    margin: EdgeInsets.symmetric(horizontal: 36),
                    borderRadius: BorderRadius.circular(30),
                    style: FlashStyle.floating,
                    position: FlashPosition.top,
                    controller: controller,
                    child: FlashBar(
                      message: Text("No",
                          style: Theme.of(context).textTheme.subtitle1),
                    )));
          },
          splashColor: Colors.deepOrange[100],
          highlightColor: Colors.deepOrange[200],
          child: Text(
            "Edit profile",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          )),
    );
  }

  _buildUserNotFoundView(String username) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesome5.frown, size: 69, color: Colors.deepOrange[200]),
          SizedBox(height: 24),
          Text("This account doesn't exist",
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 4),
          Text(
            "Try searching for another",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    ));
  }
}
