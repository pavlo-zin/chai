import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    Key key,
    @required TextEditingController searchController,
    @required bool isCloseIconVisible,
  })  : _searchController = searchController,
        _isCloseIconVisible = isCloseIconVisible,
        super(key: key);

  final TextEditingController _searchController;
  final bool _isCloseIconVisible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextFormField(
        controller: _searchController,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
            fillColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.deepOrange.withOpacity(0.2)
                    : Colors.deepOrange[50],
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
    );
  }
}
