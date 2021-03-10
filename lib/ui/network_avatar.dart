import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final bool drawBorder;
  final bool useColorAsPlaceholder;

  const NetworkAvatar({
    Key key,
    this.url,
    this.radius = 24,
    this.drawBorder = false,
    this.useColorAsPlaceholder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).canvasColor,
            width: drawBorder ? 5.0 : 0.0,
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6969),
        child: url == null
            ? SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: useColorAsPlaceholder
                    ? Container(color: Colors.deepOrange[200])
                    : Image(
                        image: AssetImage('assets/avatar.png'),
                        fit: BoxFit.cover,
                      ))
            : CachedNetworkImage(
                width: radius * 2,
                height: radius * 2,
                imageUrl: url,
                fit: BoxFit.cover),
      ),
    );
  }
}
