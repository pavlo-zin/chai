import 'package:animated_text_kit/animated_text_kit.dart';
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
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 278,
            height: 183,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                            color: Theme.of(context).primaryColorLight)),
                    color: Theme.of(context).primaryColorDark,
                    colorBlendMode: BlendMode.color,
                    imageUrl:
                        "https://i.giphy.com/media/2JUwr3tnfiQJa/giphy.webp",
                  ),
                ),
                TyperAnimatedTextKit(
                  speed: Duration(milliseconds: 200),
                  pause: Duration(milliseconds: 100),
                  isRepeatingAnimation: false,
                  curve: Curves.fastOutSlowIn,
                  textAlign: TextAlign.center,
                  text: ["Feels\nempty\nhere"],
                  textStyle: Theme.of(context).textTheme.headline4.copyWith(
                      height: 1,
                      letterSpacing: 2,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                )
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: Text(
              "Go ahead and search for someone to follow or write something yourself!",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )),
    );
  }
}
