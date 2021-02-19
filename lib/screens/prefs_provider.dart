import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider {
  PrefsProvider(this.prefs);

  final SharedPreferences prefs;

  static const onboardingCompleteKey = 'onboardingComplete';
  static const verificationId = 'verificationId';

  Future<void> setOnboardingComplete() async {
    await prefs.setBool(onboardingCompleteKey, true);
  }

  bool isOnboardingComplete() => prefs.getBool(onboardingCompleteKey) ?? false;

  Future<void> setVerificationId(String id) async {
    await prefs.setString(verificationId, id);
  }

  String getVerificationId() => prefs.getString(verificationId);

  Future<void> clear() async {
    await prefs.clear();
  }
}
