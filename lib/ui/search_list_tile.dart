import 'package:chai/models/chai_user.dart';
import 'package:flutter/material.dart';

import 'network_avatar.dart';

class SearchListTile extends StatelessWidget {
  const SearchListTile({
    Key key,
    @required this.context,
    @required this.user,
    @required this.index,
    @required this.onTap,
  }) : super(key: key);

  final BuildContext context;
  final ChaiUser user;
  final int index;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onTap,
        leading: Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 2),
          child: Hero(
            tag: "searchProfilePic$index",
            child: NetworkAvatar(
              radius: 20,
              url: user.picUrl,
            ),
          ),
        ),
        title: Text(user.displayName,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text("@${user.username}",
            style: Theme.of(context).textTheme.subtitle2));
  }
}
