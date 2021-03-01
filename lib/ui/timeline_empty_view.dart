import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TimelineEmptyView extends StatelessWidget {
  const TimelineEmptyView({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 96,
                child: CachedNetworkImage(
                    color: Colors.deepOrange[700],
                    colorBlendMode: BlendMode.color,
                    imageUrl:
                        "https://i.giphy.com/media/Az1CJ2MEjmsp2/giphy.webp")),
            SizedBox(height: 32),
            Text("Feels empty here...",
                style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 8),
            Text(
              "Go ahead and search for someone to follow or write something yourself!",
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )),
    );
  }
}
