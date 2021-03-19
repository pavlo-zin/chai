import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chai/common/file_utils.dart';
import 'package:chai/models/chai_user.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lipsum/lipsum.dart' as lipsum;

class ComposePostResult {
  final String text;
  final String imagePath;

  ComposePostResult({this.text, this.imagePath});
}

class ComposePost extends StatefulWidget {
  @override
  _ComposePostState createState() => _ComposePostState();
}

class _ComposePostState extends State<ComposePost> {
  bool _isPostButtonEnabled = false;
  String postText;
  PickedFile _pickedFile;
  ScrollController scrollController;
  TextEditingController _controller = TextEditingController();
  FocusNode textFocus;

  @override
  void initState() {
    super.initState();
    textFocus = FocusNode();
    scrollController = ScrollController();
    scrollController.addListener(() {
      textFocus.unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _controller.dispose();
    textFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();
    final ChaiUser currentUser = ModalRoute.of(context).settings.arguments;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Container(
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
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      children: [
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
                                child: NetworkAvatar(
                                    radius: 24, url: currentUser.picUrl)),
                            SizedBox(width: 10),
                            Expanded(
                                child: TextFormField(
                                    controller: _controller,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPostButtonEnabled =
                                            value.isNotEmpty ||
                                                _pickedFile != null;
                                        postText = value;
                                      });
                                    },
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLength: null,
                                    maxLines: null,
                                    autofocus: true,
                                    focusNode: textFocus,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                        hintText: "What's happening?",
                                        border: InputBorder.none))),
                            SizedBox(width: 10),
                          ],
                        ),
                        _pickedFile == null
                            ? SizedBox.shrink()
                            : Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 72.0, right: 16, bottom: 200),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                                File(_pickedFile.path)))),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 24.0, top: 8),
                                      child: ClipOval(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.5),
                                          child: IconButton(
                                              padding: EdgeInsets.all(2),
                                              constraints: BoxConstraints(),
                                              icon: Icon(
                                                Feather.x,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _pickedFile = null;
                                                  _isPostButtonEnabled =
                                                      _controller
                                                          .text.isNotEmpty;
                                                });
                                                _focusAfterDelay();
                                              }),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                  child: Row(children: [
                    IconButton(
                        icon: Icon(Feather.camera),
                        onPressed: () {
                          FileUtils.getImage(
                                  source: ImageSource.camera,
                                  maxDimension: 1000)
                              .then((value) {
                            setState(() {
                              _pickedFile = value;
                              _isPostButtonEnabled = true;
                            });
                            _focusAfterDelay();
                          });
                        }),
                    IconButton(
                        icon: Icon(Feather.image),
                        onPressed: () {
                          FileUtils.getImage(maxDimension: 1000).then((value) {
                            setState(() {
                              _pickedFile = value;
                              _isPostButtonEnabled = true;
                            });
                            _focusAfterDelay();
                          });
                        })
                  ]),
                ),
              ],
            )),
          ),
        ));
  }

  _buildSendFab(
      FirestoreProvider firestore, ChaiUser user, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: SizedBox(
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
                Navigator.pop(
                    context,
                    ComposePostResult(
                        text: postText,
                        imagePath:
                            _pickedFile == null ? null : _pickedFile.path));
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
                : Theme.of(context).textSelectionTheme.selectionColor,
            label: Text("Send",
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: _isPostButtonEnabled
                        ? Colors.white
                        : Colors.white.withOpacity(0.8))),
          ),
        ),
      ),
    );
  }

  _focusAfterDelay() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 1));
    FocusScope.of(context).requestFocus(textFocus);
  }
}
