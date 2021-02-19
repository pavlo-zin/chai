import 'package:chai/screens/common/theme.dart';
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
        appBar: AppBar(
            backgroundColor: Theme.of(context).canvasColor, elevation: 0),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Image(image: AssetImage("assets/logo.png")),
                  width: 150,
                  height: 65,
                ),
                SizedBox(height: 32),
                // SizedBox(
                //   width: 145,
                //   child: ElevatedButton(
                //     onPressed: () =>
                //         Navigator.pushNamed(context, "/create_account"),
                //     child: Text("Create account"),
                //   ),
                // ),
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
