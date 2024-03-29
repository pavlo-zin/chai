import 'package:cached_network_image/cached_network_image.dart';
import 'package:chai/models/post.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/screens/full_screen_image_view.dart';
import 'package:chai/screens/user_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'network_avatar.dart';

class TimelineListTile extends StatelessWidget {
  const TimelineListTile(
      {Key key,
      @required this.context,
      @required this.post,
      @required this.index,
      this.onOpenUserDetails,
      this.refreshTimeStream = const Stream.empty(),
      this.isUserDetails = false})
      : super(key: key);

  final BuildContext context;
  final Stream<bool> refreshTimeStream;
  final Post post;
  final int index;
  final Function onOpenUserDetails;
  final bool isUserDetails;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();
    return Column(
      children: [
        ListTile(
            enableFeedback: false,
            onTap: () {},
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            leading: InkResponse(
                onTap: onOpenUserDetails,
                child: NetworkAvatar(url: post.userInfo.picUrl)),
            title: Transform.translate(
              offset: const Offset(-8, 0),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 0,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: onOpenUserDetails,
                        child: Text(post.userInfo.displayName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: onOpenUserDetails,
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
                        stream: refreshTimeStream,
                        builder: (context, snapshot) {
                          return Expanded(
                            flex: 0,
                            child: Text(_humanizeTime(post.timestamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                        fontWeight: FontWeight.normal,
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
                  SizedBox(height: 2),
                  PostBody(
                    post: post,
                    isUserDetails: isUserDetails,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PostIcon(
                          context: context,
                          icon: Feather.message_circle,
                          padding:
                              EdgeInsets.only(top: 8, right: 12, bottom: 8),
                          text: '',
                          onPressed: () {}),
                      LikeButton(
                        onTap: (_) => firestore.togglePostLike(post),
                        circleColor: CircleColor(
                            start: Theme.of(context).primaryColorLight,
                            end: Theme.of(context).primaryColorDark),
                        bubblesColor: BubblesColor(
                          dotPrimaryColor: Theme.of(context).primaryColor,
                          dotSecondaryColor: Theme.of(context).primaryColorDark,
                        ),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_outline,
                            color: isLiked
                                ? Colors.redAccent
                                : Theme.of(context).iconTheme.color,
                            size: 18,
                          );
                        },
                        isLiked: firestore.isLikedByMe(post),
                        likeCount: post.likesCount,
                        likeCountPadding: EdgeInsets.zero,
                        countBuilder: (int count, bool isLiked, String text) {
                          var color = isLiked
                              ? Colors.redAccent
                              : Theme.of(context).hintColor;
                          Widget result;
                          if (count == 0) {
                            result = Visibility(
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: false,
                              child: Text(
                                text,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(color: color),
                              ),
                            );
                          } else
                            result = Text(
                              text,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(color: color),
                            );
                          return result;
                        },
                      ),
                      PostIcon(
                          context: context,
                          icon: Feather.share,
                          onPressed: () {})
                    ],
                  )
                ],
              ),
            )),
        Divider(height: 0)
      ],
    );
  }
}

class PostIcon extends StatelessWidget {
  final EdgeInsets padding;
  final IconData icon;
  final String text;
  final Function onPressed;

  const PostIcon({
    Key key,
    @required this.context,
    this.padding =
        const EdgeInsets.only(top: 8, right: 12, bottom: 8, left: 12),
    this.icon,
    this.text = '',
    this.onPressed,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
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
}

class PostBody extends StatelessWidget {
  final Post post;
  final bool isUserDetails;

  const PostBody({
    Key key,
    @required this.post,
    @required this.isUserDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showText = post.postText != null && post.postText.isNotEmpty;
    final showImage = post.imageInfo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showText) PostText(post: post),
        if (showImage) PostImage(post: post, isUserDetails: isUserDetails),
      ],
    );
  }
}

class PostImage extends StatelessWidget {
  const PostImage({Key key, @required this.post, @required this.isUserDetails})
      : super(key: key);

  final Post post;
  final bool isUserDetails;

  @override
  Widget build(BuildContext context) {
    final heroTag = isUserDetails ? "details${post.id}" : post.id;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: post.imageInfo.size.aspectRatio,
              child: Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                    placeholder: (context, _) =>
                        Container(color: post.imageInfo.placeholderColor),
                    imageUrl: post.imageInfo.url,
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () => _openImage(context, heroTag),
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )),
          )
        ],
      ),
    );
  }

  _openImage(BuildContext context, String heroTag) =>
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          pageBuilder: (_, __, ___) =>
              FullScreenImageView(post.imageInfo, heroTag),
        ),
      );
}

class PostText extends StatelessWidget {
  const PostText({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ParsedText(
        text: post.postText,
        style: Theme.of(context).textTheme.subtitle1,
        parse: [
          MatchText(
            renderWidget: ({String text, String pattern}) {
              return RawMaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_details',
                        arguments: UserDetailsArgs(
                            userIsKnown: false,
                            username: text,
                            profilePicHeroTag: ''));
                  },
                  child: Text(text,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: Theme.of(context).primaryColorDark)));
            },
            pattern: r'@[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]',
          )
        ]);
  }
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
