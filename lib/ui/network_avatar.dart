import 'package:cached_network_image/cached_network_image.dart';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(6969),
      child: CachedNetworkImage(
          width: radius * 2,
          height: radius * 2,
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator()),
    );
  }
}
