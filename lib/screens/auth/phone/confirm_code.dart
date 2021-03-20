import 'package:chai/providers/prefs_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../providers/auth_provider.dart';

class ConfirmCode extends StatefulWidget {
  @override
  _ConfirmCodeState createState() => _ConfirmCodeState();
}

class _ConfirmCodeState extends State<ConfirmCode> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final authProvider = context.watch<AuthProvider>();
    final PhoneNumber phone =
        (ModalRoute.of(context).settings.arguments as Tuple2).item1;
    final ConfirmationResult confirmationResult =
        (ModalRoute.of(context).settings.arguments as Tuple2).item2;

    String code;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            CupertinoButton(
                onPressed: () {
                  if (_formKey.currentState.validate() && kIsWeb) {
                    _formKey.currentState.save();
                    confirmationResult.confirm(code).then((value) =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> route) => false));
                  }

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
                        ? Text("${phone.dialCode} ${snapshot.data}",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(fontSize: 30))
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
