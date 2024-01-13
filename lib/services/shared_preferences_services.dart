import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/core/logger.dart';

class SharedPreferencesService {
  static const String token = "token";

  SharedPreferencesService._private();

  static SharedPreferencesService get i => _instance;

  static final SharedPreferencesService _instance =
      SharedPreferencesService._private();

  SharedPreferences? _prefs;

  // StreamController<String> _valueController = StreamController<String>.broadcast();
  // Stream<String> get valueStream => _valueController.stream;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      logError("Error initializing SharedPreferences: $e");
      // Handle the initialization error as needed
    }
  }

  String getValue({String key = token}) {
    if (_prefs == null) {
      // Handle the case where _prefs is not initialized
      return '';
    }
    return _prefs!.getString(key) ?? '';
  }

  Future<void> clearValue({String key = token}) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }

  Future<void> setValue({String key = token, required String value}) async {
    if (_prefs != null) {
      await _prefs!.setString(key, value);
      // _valueController.sink.add(value);
    }
  }

  // void dispose() {
  //   _valueController.close();
  // }
}
