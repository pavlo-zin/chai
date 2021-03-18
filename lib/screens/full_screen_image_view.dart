import 'package:cached_network_image/cached_network_image.dart';
import 'package:chai/models/post.dart';
import 'package:chai/ui/photo_view_swipe.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageView extends StatelessWidget {
  final PostImageInfo imageInfo;

  FullScreenImageView(this.imageInfo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PhotoViewSwipe(
        dragDistance: 100,
        dragBgColor: imageInfo.placeholderColor,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 1.1,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: imageInfo.url),
        imageProvider: CachedNetworkImageProvider(imageInfo.url),
      ),
    );
  }
}
