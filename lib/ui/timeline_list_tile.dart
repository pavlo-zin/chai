import 'package:chai/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:tuple/tuple.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'network_avatar.dart';

class TimelineListTile extends StatelessWidget {
  const TimelineListTile({
    Key key,
    @required this.context,
    @required this.post,
    @required this.index,
    this.onProfilePicTap,
    this.refreshTimeStream = const Stream.empty(),
  }) : super(key: key);

  final BuildContext context;
  final Stream<bool> refreshTimeStream;
  final Post post;
  final int index;
  final Function onProfilePicTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
            onTap: () {},
            leading: GestureDetector(
                onTap: onProfilePicTap,
                child: onProfilePicTap == null
                    ? NetworkAvatar(url: post.userInfo.picUrl)
                    : Hero(
                        tag: 'timelineProfilePic$index',
                        child: NetworkAvatar(url: post.userInfo.picUrl))),
            title: Transform.translate(
              offset: Offset(-8, 0),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 0,
                      child: Text(post.userInfo.displayName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontWeight: FontWeight.w600)),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(post.postText,
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPostIcon(Feather.message_circle, "13", () {},
                          padding:
                              EdgeInsets.only(top: 8, right: 12, bottom: 8)),
                      _buildPostIcon(Feather.heart, "69", () {}),
                      _buildPostIcon(Feather.share, "", () {}),
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
