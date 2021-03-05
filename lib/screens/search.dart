import 'package:chai/models/chai_user.dart';
import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/ui/search_list_tile.dart';
import 'package:chai/ui/search_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
          child: SearchTextField(
            searchController: _searchController,
            isCloseIconVisible: _isCloseIconVisible,
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
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data[index];
                  return SearchListTile(
                      context: context,
                      user: user,
                      index: index,
                      onTap: () {
                        Navigator.pushNamed(context, '/user_details',
                            arguments: Tuple2(user, "searchProfilePic$index"));
                      });
                });
          }),
    );
  }

  _searchListener() {
    final currentText = _searchController.text;
    setState(() {
      _isCloseIconVisible = currentText.isNotEmpty;
      _query = currentText;
    });
  }
}
