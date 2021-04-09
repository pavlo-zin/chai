import 'package:chai/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.all(56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('chai', style: getLogoStyle(context)),
                SizedBox(height: 24),
                SizedBox(
                    width: 100,
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/verify_phone");
                        },
                        child: Text("Get started"),
                        style: textButtonStyle))
              ],
            ),
          ),
        ));
  }
}
