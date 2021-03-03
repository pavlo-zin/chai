import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
    return Container(
      height: 38,
      alignment: Alignment.bottomCenter,
      child: TextFormField(
        controller: _searchController,
        autofocus: true,
        cursorHeight: 16,
        autocorrect: false,
        enableSuggestions: false,
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
            fillColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.deepOrange.withOpacity(0.2)
                    : Colors.deepOrange[50],
            filled: true,
            prefixIcon:
                Icon(Feather.search, size: 18, color: Colors.deepOrange),
            suffixIcon: _isCloseIconVisible
                ? Theme(
                    data: ThemeData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: IconButton(
                      color: Colors.deepOrange,
                      icon: Icon(Feather.x_circle, size: 18),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(top: 20, bottom: 9),
            //C
            isDense: true,
            // hange this value to custom as you like
            hintText: "Search",
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(25))),
      ),
    );
  }
}
