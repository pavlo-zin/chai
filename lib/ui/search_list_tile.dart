import 'package:chai/models/chai_user.dart';
import 'package:flutter/material.dart';

import 'network_avatar.dart';

class SearchListTile extends StatelessWidget {
  const SearchListTile({
    Key key,
    @required this.context,
    @required this.user,
  }) : super(key: key);

  final BuildContext context;
  final ChaiUser user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {},
        leading: Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 2),
          child: NetworkAvatar(
            radius: 20,
            url: user.picUrl,
          ),
        ),
        title: Text(user.displayName,
            style: Theme
                .of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text("@${user.username}",
            style: Theme
                .of(context)
                .textTheme
                .subtitle2));
  }
}
