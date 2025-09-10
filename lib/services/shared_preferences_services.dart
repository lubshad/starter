import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _token = "token";
const String domainKey = "domain";
const String defaultCompanyKey = "defaultCompany";
const String serverTimeDifferenceKey = "server_time_diff_key";
String serverTimeDifferenceString = "";

const String notificationDataKey = "notification_data_key";
const String incomingCallKey = "incoming_call_key";


class SharedPreferencesService {
  Future<String> get domainUrl => getValue(key: domainKey);

  SharedPreferencesService._private();

  static SharedPreferencesService get i => _instance;

  static final SharedPreferencesService _instance =
      SharedPreferencesService._private();

  late final FlutterSecureStorage _storage;

  Future<String> get token => getValue(key: _token);

  Future<void> initialize() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  Future<String> getValue({String key = _token}) async {
    return await _storage.read(key: key) ?? '';
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<void> setValue({String key = _token, required String value}) async {
    await _storage.write(key: key, value: value);
  }
}
