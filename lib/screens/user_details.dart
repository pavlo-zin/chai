import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    final userAndIndex = ModalRoute.of(context).settings.arguments as Tuple2;
    final user = userAndIndex.item1 as ChaiUser;
    final profilePicHeroTag = userAndIndex.item2;

    return Scaffold(
        body: NestedScrollView(
            physics: const BouncingScrollPhysics(),
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
                      color: Colors.deepOrangeAccent[100],
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
                              tag: profilePicHeroTag,
                              child: ValueListenableBuilder(
                                valueListenable: _offset,
                                builder: (context, offset, _) =>
                                    AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: offset > 30 ? 0 : 1,
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
                          ),
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
                            .copyWith(fontWeight: FontWeight.bold),
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
            body: StreamBuilder<List<Post>>(
                stream: firestore.getPosts(uid: user.id, onlyForThisUser: true),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                          child: SelectableText(snapshot.error.toString(),
                              style: Theme.of(context).textTheme.headline6)),
                    );
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
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
                              return buildPostTile(snapshot.data[index], index);
                            }),
                      ),
                    ],
                  );
                })));
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
                          ? Theme.of(context).canvasColor
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
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
                      message: Text("No", style: Theme.of(context).textTheme.subtitle1),
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

  buildPostTile(Post post, int index) {
    return Column(
      children: [
        ListTile(
            onTap: () {
              log("Post id ${post.id}, uid: ${post.userInfo.id}");
            },
            leading: NetworkAvatar(url: post.userInfo.picUrl),
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
                    Expanded(
                      flex: 0,
                      child: Text(_humanizeTime(post.timestamp),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: Theme.of(context).hintColor)),
                    )
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
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Theme.of(context).hintColor))
        ]),
      ),
    );
  }

  _humanizeTime(DateTime time) {
    return timeago
        .format(time, locale: 'en_short')
        .replaceAll(RegExp("~"), '')
        .replaceAll(RegExp("min"), 'm')
        .replaceAll(RegExp(" "), '');
  }
}
