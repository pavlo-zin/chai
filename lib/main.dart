import 'dart:developer';

import 'package:chai/providers/firestore_provider.dart';
import 'package:chai/screens/about.dart';
import 'package:chai/providers/auth_provider.dart';
import 'package:chai/screens/auth/authenticator.dart';
import 'package:chai/screens/auth/complete_onboarding.dart';
import 'package:chai/screens/auth/phone/confirm_code.dart';
import 'package:chai/screens/auth/phone/phone_input.dart';
import 'package:chai/screens/auth/welcome.dart';
import 'package:chai/screens/compose_post.dart';
import 'package:chai/providers/prefs_provider.dart';
import 'package:chai/screens/search.dart';
import 'package:chai/screens/timeline.dart';
import 'package:chai/screens/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ChaiApp(sharedPreferences));
}

class ChaiApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  ChaiApp(this.sharedPreferences);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PrefsProvider>.value(value: PrefsProvider(sharedPreferences)),
        Provider<AuthProvider>.value(value: AuthProvider()),
        StreamProvider<AsyncSnapshot<User>>(
          initialData: AsyncSnapshot.waiting(),
          create: (_) => FirebaseAuth.instance.authStateChanges().map(
              (data) => AsyncSnapshot.withData(ConnectionState.active, data)),
        ),
        ProxyProvider<AsyncSnapshot<User>, FirestoreProvider>(
          update: (_, userSnapshot, __) {
            final user = userSnapshot.data;
            return FirestoreProvider(currentUid: user?.uid ?? null);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(context),
        darkTheme: buildAppTheme(context, dark: true),
        routes: {
          '/': (context) => Authenticator(),
          '/welcome': (context) => Welcome(),
          '/verify_phone': (context) => PhoneInput(),
          '/confirm_code': (context) => ConfirmCode(),
          '/complete_onboarding': (context) => CompleteOnboarding(),
          '/timeline': (context) => Timeline(),
          '/user_details': (context) => UserDetails(),
          '/compose_post': (context) => ComposePost(),
          '/about': (context) => About(),
          '/search': (context) => Search(),
        },
      ),
    );
  }
}
