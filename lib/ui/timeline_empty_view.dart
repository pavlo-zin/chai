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
                width: 300,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => CircularProgressIndicator(),
                        color: Colors.deepOrange[700],
                        colorBlendMode: BlendMode.color,
                        imageUrl:
                            "https://i.giphy.com/media/2JUwr3tnfiQJa/giphy.webp",
                      ),
                    ),
                    TyperAnimatedTextKit(
                      speed: Duration(milliseconds: 400),
                      pause: Duration(milliseconds: 200),
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
