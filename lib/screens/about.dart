import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("About chai"),
      ),
      body: Center(
        child: Image.network("https://i.giphy.com/media/WQMgnHWQdyZjO/source.gif"),
      ),
    );
  }
}