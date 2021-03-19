import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:chai/ui/timeline_list_tile.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

    return args.userIsKnown
        ? _buildUserDetailsView(args, firestore)
        : FutureBuilder<ChaiUser>(
            future: firestore.getUserByUsername(args.username),
            builder: (context, snapshot) {
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
        body: Stack(
      children: [
        CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            controller: _controller,
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).primaryColorLight,
                iconTheme: IconThemeData(color: Colors.white),
                brightness: Brightness.dark,
                elevation: 0,
                flexibleSpace: AnimatedOpacity(
                  opacity: isLoading ? 0.3 : 1,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                expandedHeight: 96,
              ),
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$username",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "$username",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Theme.of(context).hintColor),
                    ),
                    SizedBox(height: 16)
                  ],
                ),
              )),
              SliverToBoxAdapter(child: Divider(height: 8)),
              isLoading
                  ? SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverFillRemaining(
                      child: UserNotFoundView(context: context))
            ]),
        isLoading
            ? SizedBox.shrink()
            : Positioned(
                left: 16,
                top: 56 + MediaQuery.of(context).padding.top,
                child: NetworkAvatar(
                    drawBorder: true,
                    radius: 36,
                    useColorAsPlaceholder: isLoading))
      ],
    ));
  }

  _buildUserDetailsView(UserDetailsArgs args, FirestoreProvider firestore) {
    final ChaiUser user = args.user;
    final String profilePicTag = args.profilePicHeroTag;
    final headerUrl = 'https://source.unsplash.com/L82-kkEBOd0/1500x1000';

    return Scaffold(
        body: Stack(
      children: [
        CustomScrollView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            controller: _controller,
            slivers: [
              SliverAppBar(
                stretch: true,
                pinned: true,
                iconTheme: IconThemeData(color: Colors.white),
                brightness: Brightness.dark,
                elevation: 0,
                centerTitle: true,
                title: ValueListenableBuilder(
                    valueListenable: _offset,
                    builder: (context, offset, _) => AnimatedOpacity(
                          opacity: offset > 116 ? 1 : 0,
                          duration: Duration(milliseconds: 200),
                          child: Text(
                            "${user.displayName}",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                          ),
                        )),
                flexibleSpace: Container(
                  color: Theme.of(context).primaryColorLight,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      SizedBox.expand(
                        child: CachedNetworkImage(
                          placeholder: (context, _) => Container(
                              color: Theme.of(context).primaryColorLight),
                          imageUrl: headerUrl,
                          color: Theme.of(context).primaryColorDark,
                          colorBlendMode: BlendMode.color,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _offset,
                        builder: (context, offset, _) {
                          double opacity = 0;
                          if (offset >= 116 && offset <= 136) {
                            opacity = normalize(offset, 116, 136);
                          } else if (offset >= 136) {
                            opacity = 1;
                          } else {
                            opacity = 0;
                          }
                          return Stack(
                            children: [
                              SizedBox.expand(
                                child: Opacity(
                                  opacity: opacity,
                                  child: ClipRRect(
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                          sigmaX: 7, sigmaY: 7),
                                      child: CachedNetworkImage(
                                        imageUrl: headerUrl,
                                        color:
                                            Colors.deepOrange.withOpacity(0.8),
                                        colorBlendMode: BlendMode.color,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(opacity / 4))
                            ],
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: 150,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, 0.0),
                                end: Alignment(0.0, 1),
                                colors: <Color>[
                                  Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.5),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.25),
                                  Theme.of(context).primaryColor.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                expandedHeight: 96,
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
                      icon: Icon(Feather.more_horizontal))
                ],
              ),
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      Positioned(
                          left: 20,
                          child: NetworkAvatar(
                              url: user.picUrl, radius: 16, drawBorder: true)),
                      Container(
                        padding: EdgeInsets.only(right: 0, top: 8),
                        alignment: Alignment.topRight,
                        child: firestore.isUserMe(user)
                            ? buildEditProfileButton(context)
                            : buildFollowButton(context, user, firestore),
                      ),
                    ]),
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
                    SizedBox(height: 16)
                  ],
                ),
              )),
              SliverToBoxAdapter(child: Divider(height: 8)),
              FutureBuilder<Object>(
                  future: Future.delayed(Duration(milliseconds: 300)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      return TimelineView(firestore: firestore, user: user);
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(12.0),
                        sliver: SliverToBoxAdapter(
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    backgroundColor: null,
                                  ))),
                        ),
                      );
                    }
                    return SliverToBoxAdapter(child: SizedBox.shrink());
                  })
            ]),
        ValueListenableBuilder(
          valueListenable: _offset,
          builder: (context, offset, _) {
            double paddingTop = 56 + MediaQuery.of(context).padding.top;
            return Positioned(
                left: offset > 0 && offset < 41 ? 16 + offset * 0.5 : 16,
                top: offset < 0 ? paddingTop - offset : paddingTop,
                child: Hero(
                  tag: profilePicTag,
                  child: ValueListenableBuilder(
                    valueListenable: _offset,
                    builder: (context, offset, _) => Opacity(
                      opacity: offset >= 40 ? 0 : 1,
                      child: NetworkAvatar(
                        drawBorder: true,
                        radius: offset <= 0
                            ? 36
                            : offset >= 40.0
                                ? 20
                                : 36 - offset * 0.5,
                        url: user.picUrl,
                      ),
                    ),
                  ),
                ));
          },
        ),
      ],
    ));
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
            return SizedBox(
                width: 100,
                child: RawMaterialButton(
                  onPressed: () {},
                ));

          final following = snapshot.data.item2 != null;
          final currentUser = snapshot.data.item1;

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
                splashColor:
                    Theme.of(context).primaryColorLight.withOpacity(0.8),
                highlightColor: Theme.of(context).primaryColorLight,
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
          splashColor: Theme.of(context).primaryColorLight.withOpacity(0.8),
          highlightColor: Theme.of(context).primaryColorLight,
          child: Text(
            "Edit profile",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          )),
    );
  }

  double normalize(double value, double min, double max) {
    return (value - min) / (max - min);
  }
}

class UserNotFoundView extends StatelessWidget {
  const UserNotFoundView({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72.0),
      child: Column(
        children: [
          Icon(FontAwesome5.frown, size: 64),
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
    );
  }
}

class TimelineView extends StatelessWidget {
  final FirestoreProvider firestore;
  final ChaiUser user;

  const TimelineView({Key key, this.firestore, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
        stream: firestore.getPosts(uid: user.id, onlyForThisUser: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return SliverPadding(
              padding: EdgeInsets.only(bottom: 56),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return TimelineListTile(
                    context: context,
                    post: snapshot.data[index],
                    index: index,
                    isUserDetails: true);
              }, childCount: snapshot.data.length)),
            );
          }
          return SliverToBoxAdapter(child: SizedBox.shrink());
        });
  }
}
