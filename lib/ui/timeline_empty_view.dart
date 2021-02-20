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
                height: 80,
                child: Image(image: AssetImage("assets/chai_icon.png"))),
            SizedBox(height: 16),
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
