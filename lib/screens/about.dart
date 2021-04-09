import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                textBaseline: TextBaseline.ideographic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text("chai",
                      style: Theme.of(context).textTheme.headline1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).accentColor,
                          letterSpacing: -5)),
                  SizedBox(width: 2),
                  FutureBuilder<String>(
                      future: getAppVersion(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Text(
                            "v${snapshot.data}",
                            style: Theme.of(context).textTheme.overline,
                          );
                        }
                        return SizedBox.shrink();
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "chai is an open service that’s home to a world of diverse people, perspectives, ideas, and information.",
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 18),
              ),
            ),
            SizedBox(height: 28),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 36, bottom: 36),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://source.unsplash.com/NtXEet79qfI',
                        color: Colors.black,
                        colorBlendMode: BlendMode.color,
                        fit: BoxFit.cover,
                      ),
                      CachedNetworkImage(
                        imageUrl: 'https://source.unsplash.com/PGnqT0rXWLs',
                        color: Colors.black,
                        colorBlendMode: BlendMode.color,
                        fit: BoxFit.cover,
                      ),
                      CachedNetworkImage(
                        imageUrl: 'https://source.unsplash.com/gYdjZzXNWlg',
                        color: Colors.black,
                        colorBlendMode: BlendMode.color,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "chai\nis\nwhat’s\nhappening",
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 40,
                              letterSpacing: 2,
                              backgroundColor: Theme.of(context).accentColor,
                              height: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "and what\npeople are\ntalking\nabout\nright now.",
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 40,
                              letterSpacing: 2,
                              backgroundColor: Theme.of(context).accentColor,
                              height: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "we\nserve",
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 56,
                              letterSpacing: 2,
                              backgroundColor: Colors.white,
                              color: Colors.black,
                              height: 1,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 56),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "the public\nconversation,",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 32,
                              letterSpacing: 2,
                              backgroundColor: Colors.white,
                              color: Colors.black,
                              height: 1,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "that’s why\nit matters to us\nthat people have\na free and safe",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 18,
                              letterSpacing: 2,
                              backgroundColor: Colors.white,
                              color: Colors.black,
                              height: 1,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "space to talk.",
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 40,
                              letterSpacing: 2,
                              backgroundColor: Theme.of(context).accentColor,
                              height: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 69)
          ],
        ),
      ),
    );
  }

  Future<String> getAppVersion() async {
    var packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
