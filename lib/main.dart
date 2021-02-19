import 'package:chai/screens/about.dart';
import 'package:chai/screens/auth/auth_provider.dart';
import 'package:chai/screens/auth/authenticator.dart';
import 'package:chai/screens/auth/complete_onboarding.dart';
import 'package:chai/screens/auth/phone/confirm_code.dart';
import 'package:chai/screens/auth/phone/phone_input.dart';
import 'package:chai/screens/auth/welcome.dart';
import 'package:chai/screens/compose_post.dart';
import 'package:chai/screens/firestore_provider.dart';
import 'package:chai/screens/prefs_provider.dart';
import 'package:chai/screens/search.dart';
import 'package:chai/screens/timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider()),
        StreamProvider<User>.value(value: FirebaseAuth.instance.authStateChanges()),
        ProxyProvider<User, FirestoreProvider>(
          update: (_, user, __) => FirestoreProvider(uid: user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'Cherry',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          canvasColor: Colors.white,
          textTheme: GoogleFonts.notoSansTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              iconTheme: IconThemeData(color: Colors.black87),
              color: Colors.white),
          primarySwatch: Colors.deepOrange,
        ),
        routes: {
          '/': (context) => Authenticator(),
          '/welcome': (context) => Welcome(),
          '/verify_phone': (context) => PhoneInput(),
          '/confirm_code': (context) => ConfirmCode(),
          '/complete_onboarding': (context) => CompleteOnboarding(),
          '/timeline': (context) => Timeline(),
          '/compose_post': (context) => ComposePost(),
          '/about': (context) => About(),
          '/search': (context) => Search(),
        },
      ),
    );
  }
}
