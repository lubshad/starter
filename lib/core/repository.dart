// ignore_for_file: depend_on_referenced_packages

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/utils.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../features/authentication/phone_auth/phone_auth_mixin.dart';
import '../features/notification/models/notification_model.dart';
import '../features/profile_screen/profile_details_model.dart';
import '../models/name_id.dart';
import '../services/shared_preferences_services.dart';
import 'api_constants.dart';
import 'app_config.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'pagination_response.dart';

final diologger = PrettyDioLogger(
  requestHeader: true,
  responseHeader: true,
  requestBody: true,
  enabled: kDebugMode,
);

class DataRepository {
  DataRepository._private();
  late final Dio _client;

  bool initialized = false;
  Future<void> initialize() async {
    if (initialized) return;
    final domainUrl = await SharedPreferencesService.i.domainUrl;
    _client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        baseUrl: domainUrl == ""
            ? appConfig.baseUrl
            : domainUrl + appConfig.slugUrl,
        contentType: "application/json",
      ),
    );
    var cookieJar = CookieJar(ignoreExpires: false);
    _client.interceptors.add(CookieManager(cookieJar));
    _client.interceptors.add(TokenAuthInterceptor());
    _client.interceptors.add(
      diologger,
    );
    initialized = true;
  }

  static DataRepository get i => _instance;
  static final DataRepository _instance = DataRepository._private();

  void setBaseUrl(String text) {
    _client.options.baseUrl = text + appConfig.slugUrl;
  }

  Future<String> login({
    required String username,
    required String password,
    String? totp,
    bool donotAsk = false,
  }) async {
    Map<String, dynamic> data = {
      "login": username,
      "password": password,
      "totp_token": totp,
    };

    if (donotAsk == true) {
      data.addAll({"do_not_ask": donotAsk});
    }
    var response = await _client.post(
      APIConstants.login,
      data: FormData.fromMap(data),
    );
    response = await _client.post(
      APIConstants.login,
      data: FormData.fromMap(data),
    );
    final allowedCompanies = (response.data["companies"] as List)
        .map((e) => NameId.fromMap(e)!)
        .toList();
    final defaultComapnyId = (response.data["company"] as List).first as int;
    final defaultCompany = allowedCompanies.firstWhereOrNull(
      (element) => element.id == defaultComapnyId,
    );
    SharedPreferencesService.i.setValue(
      key: defaultCompanyKey,
      value: defaultCompany?.toJson() ?? "",
    );
    return response.data["Token"];
  }

  Future<Response> updateDevice(BaseDeviceInfo deviceInfo) async {
    final response = await _client.put(
      APIConstants.updateDevice,
      data: deviceInfo.data,
    );
    return response;
  }

  Future<Response> updateProfileDetails(
    ProfileDetailsModel profileDetails,
  ) async {
    final response = await _client.put(
      APIConstants.updateprofile,
      data: profileDetails.toMap(),
    );
    return response;
  }

  Future<ProfileDetailsModel> fetchProfileDetails() async {
    final response = await _client.get(APIConstants.profileDetails);
    return ProfileDetailsModel.fromMap(response.data);
  }

  Future<Response> updateToken({required String token}) async {
    final response = await _client.put(
      APIConstants.fcmtoken,
      data: FormData.fromMap({"fcm_token": token}),
    );
    return response;
  }

  Future<DateTime> serverTime() async => DateTime.now();

  Future<PaginationResponse<NotificationModel>> fetchNotifications({
    required int pageNo,
  }) async {
    final response = await _client.get(APIConstants.notifications);
    return PaginationResponse.fromJson(
      response.data,
      (json) => NotificationModel.fromMap(json),
    );
  }
}
