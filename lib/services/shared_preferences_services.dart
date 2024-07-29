import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

const String _token = "token";
const String domainKey = "domain";

class SharedPreferencesService {
  String get domainUrl => getValue(key: domainKey);

  SharedPreferencesService._private();

  static SharedPreferencesService get i => _instance;

  static final SharedPreferencesService _instance =
      SharedPreferencesService._private();

  late final Box _prefs;

  String get token => _prefs.get(_token) ?? "";

  Future<void> initialize() async {
    final key = [
      108,
      12,
      208,
      199,
      135,
      235,
      129,
      43,
      230,
      7,
      237,
      38,
      252,
      146,
      16,
      29,
      244,
      205,
      186,
      135,
      102,
      124,
      35,
      231,
      245,
      42,
      198,
      211,
      229,
      140,
      53,
      186
    ];
    Directory? appDir;
    if (!kIsWeb) {
      appDir = await getApplicationDocumentsDirectory();
    }
    final encryptionCipher = HiveAesCipher(key);
    _prefs = await Hive.openBox("my-box",
        encryptionCipher: encryptionCipher, path: appDir?.path);
  }

  String getValue({String key = _token}) {
    return _prefs.get(key) ?? '';
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  Future<void> setValue({String key = _token, required String value}) async {
    await _prefs.put(key, value);
  }
}
