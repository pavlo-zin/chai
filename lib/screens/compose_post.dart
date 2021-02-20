import 'dart:developer';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ComposePost extends StatefulWidget {
  @override
  _ComposePostState createState() => _ComposePostState();
}

class _ComposePostState extends State<ComposePost> {
  bool _isPostButtonEnabled = false;
  String postText;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();

    return Container(
      padding: EdgeInsets.only(left: 8, right: 24, top: 16),
      color: Theme.of(context).canvasColor,
      child: SafeArea(
        child: Scaffold(
          body: StreamBuilder<ChaiUser>(
              stream: firestore.getUser(), // todo: remove this and pass user from Timeline
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Cancel",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600))),
                          _buildSendFab(firestore, snapshot, context),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 16),
                          NetworkAvatar(radius: 24, url: snapshot.data?.picUrl),
                          SizedBox(width: 16),
                          Expanded(
                              child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      _isPostButtonEnabled = value.isNotEmpty;
                                      postText = value;
                                    });
                                  },
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLength: null,
                                  maxLines: null,
                                  autofocus: true,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                      hintText: "What's happening?",
                                      border: InputBorder.none)))
                        ],
                      ),
                    ],
                  );
                } else
                  return Container();
              }),
        ),
      ),
    );
  }

  _buildSendFab(FirestoreProvider firestore, AsyncSnapshot<ChaiUser> snapshot,
      BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_isPostButtonEnabled) {
          log(postText);
          firestore
              .submitPost(Post(
                  userInfo: snapshot.data,
                  postText: postText,
                  timestamp: DateTime.now()))
              .then((value) {
            Navigator.pop(context);
          });
        } else {
          return null;
        }
      },
      elevation: _isPostButtonEnabled ? 8 : 4,
      highlightElevation: _isPostButtonEnabled ? 12 : 8,
      splashColor: _isPostButtonEnabled
          ? Theme.of(context).splashColor
          : Colors.transparent,
      backgroundColor: _isPostButtonEnabled
          ? Theme.of(context).accentColor
          : Colors.deepOrange[200],
      icon: Icon(Icons.send),
      label: Text("Send"),
    );
  }
}
