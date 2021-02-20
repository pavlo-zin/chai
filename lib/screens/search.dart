import 'package:chai/models/chai_user.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/ui/network_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();

  String _query;
  bool _isCloseIconVisible = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: SizedBox(
            height: 38,
            child: TextFormField(
              controller: _searchController,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                  fillColor: Colors.deepOrange[50],
                  filled: true,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _isCloseIconVisible
                      ? Theme(
                          data: ThemeData(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: IconButton(
                            color: Colors.deepOrangeAccent,
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  hintText: "Search",
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(25))),
            ),
          ),
        ),
        actions: [
          CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ))
        ],
      ),
      body: FutureBuilder<List<ChaiUser>>(
          future: firestore.searchUsers(_query),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return ListView(children: _buildUserTiles(snapshot.data));
          }),
    );
  }

  _buildUserTiles(List<ChaiUser> users) {
    return users
        .map((user) => ListTile(
            onTap: () {},
            leading: Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 2),
              child: NetworkAvatar(
                radius: 20,
                url: user.picUrl,
              ),
            ),
            title: Text(user.displayName,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text("@${user.username}",
                style: Theme.of(context).textTheme.subtitle2)))
        .toList();
  }

  _searchListener() {
    final currentText = _searchController.text;
    setState(() {
      _isCloseIconVisible = currentText.isNotEmpty;
      _query = currentText;
    });
  }
}
