import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ButtonStyle textButtonStyle = ButtonStyle(
    textStyle:
        MaterialStateProperty.all(TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
    overlayColor: MaterialStateProperty.all(Colors.deepOrange[300]),
    foregroundColor: MaterialStateProperty.all(Colors.white));

final InputDecoration textInputDecoration = InputDecoration(
    enabledBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.black26),
));

ThemeData buildAppTheme(BuildContext context, {bool dark = false}) {
  return ThemeData(
    iconTheme: IconThemeData(color: dark ? Colors.white54 : Colors.black45),
    dividerColor: dark ? Colors.white24 : Colors.black12,
    disabledColor: dark ? Colors.white54 : Colors.black45,
    hintColor: dark ? Colors.white54 : Colors.black54,
    textSelectionColor:
        dark ? Colors.deepOrange[900].withOpacity(0.7) : Colors.deepOrange[200],
    canvasColor: dark ? Colors.black : Colors.white,
    textTheme: Theme.of(context).textTheme.apply(
        displayColor: dark ? Colors.white70 : Colors.black87,
        bodyColor: dark ? Colors.white.withOpacity(0.85) : Colors.black87),
    appBarTheme: AppBarTheme(
        elevation: 0,
        brightness: dark ? Brightness.dark : Brightness.light,
        iconTheme: IconThemeData(color: Colors.deepOrange),
        color: dark ? Colors.black : Colors.white),
    primarySwatch: Colors.deepOrange,
  );
}
