import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String token = "token";

  SharedPreferencesService._private();

  static SharedPreferencesService get i => _instance;

  static final SharedPreferencesService _instance =
      SharedPreferencesService._private();

  SharedPreferences? _prefs;

  // final _valueController = StreamController<String>.broadcast();
  // Stream<String> get valueStream => _valueController.stream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getValue({String key = token}) {
    return _prefs!.getString(key) ?? '';
  }

  clearValue({String key = token}) async {
    await _prefs!.remove(key);
  }

  Future<void> setValue({String key = token, required String value}) async {
    await _prefs!.setString(key, value);
    // _valueController.sink.add(value);
  }

  // void dispose() {
  //   _valueController.close();
  // }
}
