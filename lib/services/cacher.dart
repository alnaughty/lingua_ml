import 'package:shared_preferences/shared_preferences.dart';

class Cacher {
  SharedPreferences? _preference;

  ///Initialize shared_preferences
  void init() async {
    _preference = await SharedPreferences.getInstance();
  }

  bool isNewUser() {
    bool? _n = _preference?.getBool("is_new");
    return _n ?? true;
  }

  void nowOld() {
    _preference?.setBool("is_new", false);
  }
}
