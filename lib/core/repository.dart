// ignore_for_file: depend_on_referenced_packages

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/utils.dart';
import '../features/authentication/phone_auth/phone_auth_mixin.dart';
import '../features/chat/agora_utils.dart';
import '../features/notification/models/notification_model.dart';
import '../features/profile_screen/profile_details_model.dart';
import '../models/name_id.dart';
import '../services/shared_preferences_services.dart';
import 'api_constants.dart';
import 'app_config.dart';
import 'error_exception_handler.dart';
import 'interceptors.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'universal_argument.dart';

bool validateStatus(int? status) {
  List validStatusCodes = [304, 200, 201, 204];
  return validStatusCodes.contains(status);
}

class DataRepository with ErrorExceptionHandler {
  final Dio _client = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 120),
      validateStatus: validateStatus,
      baseUrl: SharedPreferencesService.i.domainUrl == ""
          ? appConfig.baseUrl
          : SharedPreferencesService.i.domainUrl + appConfig.slugUrl,
      receiveDataWhenStatusError: true,
      contentType: "application/json",
    ),
  );

  static DataRepository get i => _instance;
  static final DataRepository _instance = DataRepository._private();
  void setBaseUrl(String text) {
    _client.options.baseUrl = text + appConfig.slugUrl;
  }

  DataRepository._private() {
    var cookieJar = CookieJar(ignoreExpires: false);
    _client.interceptors.add(CookieManager(cookieJar));
    _client.interceptors.add(TokenAuthInterceptor());
    _client.interceptors.add(LoggingInterceptor());
  }

  Future<String> login({
    required String username,
    required String password,
    String? totp,
    bool donotAsk = false,
  }) async {
    try {
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
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> updateDevice(BaseDeviceInfo deviceInfo) async {
    try {
      final response = await _client.put(
        APIConstants.updateDevice,
        data: deviceInfo.data,
      );
      return response;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> updateProfileDetails(
    ProfileDetailsModel profileDetails,
  ) async {
    try {
      final response = await _client.put(
        APIConstants.updateprofile,
        data: profileDetails.toMap(),
      );
      return response;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ProfileDetailsModel> fetchProfileDetails() async {
    try {
      final response = await _client.get(APIConstants.profileDetails);
      return ProfileDetailsModel.fromMap(response.data);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> updateToken({required String token}) async {
    try {
      final response = await _client.put(
        APIConstants.fcmtoken,
        data: FormData.fromMap({"fcm_token": token}),
      );
      return response;
    } catch (e) {
      throw handleError(e);
    }
  }

  serverTime() {}

  Future<PaginationModel<NotificationModel>> fetchNotifications({
    required int pageNo,
  }) async {
    try {
      final response = await _client.get(APIConstants.notifications);
      final newItems = (response.data["data"] as List)
          .map((e) => NotificationModel.fromMap(e))
          .toList();
      return PaginationModel.fromMap(response.data, newItems);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AgoraConfig> generateAgoraToken(ProfileDetailsModel profile) async {
    try {
      final response = await Dio().get(
        "https://generateusertoken-q3hnzdhmya-uc.a.run.app",
        queryParameters: {
          "username": profile.email,
          "avatarurl": profile.image,
          "nickname": profile.name,
        },
      );
      return AgoraConfig.fromMap(response.data);
    } catch (e) {
      throw handleError(e);
    }
  }
}
