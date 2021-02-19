import 'package:chai/screens/prefs_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';

class ConfirmCode extends StatefulWidget {
  @override
  _ConfirmCodeState createState() => _ConfirmCodeState();
}

class _ConfirmCodeState extends State<ConfirmCode> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final authProvider = context.watch<AuthProvider>();
    final PhoneNumber phone = ModalRoute.of(context).settings.arguments;

    String code;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            CupertinoButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final prefs = context.read<PrefsProvider>();
                    authProvider.signInWithPhone(code, prefs).then((value) =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> route) => false));
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ))
          ],
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 24),
              FutureBuilder<String>(
                  future: PhoneNumber.getParsableNumber(phone),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Text("+${snapshot.data}",
                            style: Theme.of(context).textTheme.headline4)
                        : Text("");
                  }),
              SizedBox(height: 8),
              Text("We've sent you an SMS with the code"),
              SizedBox(height: 24),
              Form(
                key: _formKey,
                child: SizedBox(
                  width: 100,
                  child: TextFormField(
                      style: Theme.of(context).textTheme.headline6,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          counter: SizedBox.shrink(),
                          hintText: 'Code',
                          helperText: ' '),
                      onSaved: (String value) => code = value),
                ),
              ),
            ],
          ),
        ));
  }
}
