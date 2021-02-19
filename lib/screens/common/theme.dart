import 'package:flutter/material.dart';

final ButtonStyle textButtonStyle = ButtonStyle(
    textStyle:
        MaterialStateProperty.all(TextStyle(fontWeight: FontWeight.w500)),
    backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
    overlayColor: MaterialStateProperty.all(Colors.deepOrange[300]),
    foregroundColor: MaterialStateProperty.all(Colors.white));

final InputDecoration textInputDecoration = InputDecoration(
    enabledBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.black26),
));
