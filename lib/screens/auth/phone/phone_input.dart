import 'dart:developer';

import 'package:chai/screens/prefs_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';

class PhoneInput extends StatefulWidget {
  @override
  _PhoneInputState createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  PhoneNumber phone;
  final _formKey = GlobalKey<FormState>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Container(
      color: Theme.of(context).canvasColor,
      child: SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Column(
              children: [
                _buildNextButton(authProvider, context),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Your phone",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 56),
                          child: Text(
                            "Please choose your country code and enter your phone number",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                        SizedBox(height: 24),
                        Divider(height: 1),
                        _buildPhoneNumberInput(context),
                        Divider(height: 1),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _buildNextButton(AuthProvider authProvider, BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 100,
        child: CupertinoButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                log(phone.toString());
                authProvider.verifyPhoneNumber(phone.phoneNumber, error: (e) {
                  _scaffoldKey.currentState
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }, codeSent: (String id, int resendToken) {
                  final prefs = context.read<PrefsProvider>();
                  prefs.setVerificationId(id);
                  Navigator.pushNamed(context, "/confirm_code",
                      arguments: phone);
                });
              }
            },
            child: Text(
              "Next",
              style: TextStyle(fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  _buildPhoneNumberInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56),
      child: Form(
        key: _formKey,
        child: InternationalPhoneNumberInput(
          autoFocus: true,
          selectorConfig: SelectorConfig(
            setSelectorButtonAsPrefixIcon: false,
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          ),
          ignoreBlank: false,
          initialValue: PhoneNumber(isoCode: 'TH', phoneNumber: "666666666"),
          formatInput: true,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          inputDecoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16),
              border: InputBorder.none),
          textStyle: Theme.of(context).textTheme.subtitle1,
          selectorTextStyle: Theme.of(context).textTheme.subtitle1,
          searchBoxDecoration: InputDecoration(
              hintText: "Search",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 15),
              prefixIcon:
                  Icon(Feather.search, size: 18, color: Theme.of(context).hintColor)),
          onInputChanged: (PhoneNumber value) => phone = value,
        ),
      ),
    );
  }
}
