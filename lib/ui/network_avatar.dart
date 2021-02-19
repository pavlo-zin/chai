import 'package:flutter/material.dart';

class NetworkAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const NetworkAvatar({
    Key key,
    this.url,
    this.radius = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.deepOrange[100],
        radius: radius,
        backgroundImage: NetworkImage(url));
  }
}