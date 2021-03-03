import 'dart:math';

import 'package:chai/models/chai_user.dart';
import 'package:chai/models/post.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:lipsum/lipsum.dart' as lipsum;

class ComposePost extends StatefulWidget {
  @override
  _ComposePostState createState() => _ComposePostState();
}

class _ComposePostState extends State<ComposePost> {
  bool _isPostButtonEnabled = false;
  String postText;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();
    final ChaiUser currentUser = ModalRoute.of(context).settings.arguments;

    return Container(
      padding: EdgeInsets.only(right: 16),
      color: Theme.of(context).canvasColor,
      child: SafeArea(
        child: Scaffold(
            body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel",
                        style: TextStyle(fontWeight: FontWeight.w600))),
                _buildSendFab(firestore, currentUser, context),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16),
                GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _controller.text = lipsum.createWord(
                            numWords: Random().nextInt(30) + 5);
                        postText = _controller.value.text;
                        _isPostButtonEnabled = true;
                      });
                    },
                    child: NetworkAvatar(radius: 24, url: currentUser.picUrl)),
                SizedBox(width: 16),
                Expanded(
                    child: TextFormField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {
                            _isPostButtonEnabled = value.isNotEmpty;
                            postText = value;
                          });
                        },
                        textCapitalization: TextCapitalization.sentences,
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
        )),
      ),
    );
  }

  _buildSendFab(
      FirestoreProvider firestore, ChaiUser user, BuildContext context) {
    return SizedBox(
      width: 72,
      height: 36,
      child: AbsorbPointer(
        absorbing: !_isPostButtonEnabled,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_isPostButtonEnabled) {
              setState(() {
                _isPostButtonEnabled = false;
              });
              firestore
                  .submitPost(Post(
                      userInfo: user,
                      postText: postText,
                      timestamp: DateTime.now()))
                  .then((value) {
                Navigator.pop(context, true);
              });
            } else {
              return null;
            }
          },
          elevation: 0,
          highlightElevation: 0,
          splashColor: _isPostButtonEnabled
              ? Theme.of(context).splashColor
              : Colors.transparent,
          backgroundColor: _isPostButtonEnabled
              ? Theme.of(context).primaryColor
              : Theme.of(context).textSelectionColor,
          label: Text("Send",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}
