import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import '../features/profile_screen/profile_details_model.dart';
import 'api_constants.dart';
import 'app_config.dart';
import 'error_exception_handler.dart';
import 'interceptors.dart';

bool validateStatus(int? status) {
  List validStatusCodes = [
    304,
    200,
    201,
    204
  ];
  return validStatusCodes.contains(status);
}

class DataRepository with ErrorExceptionHandler {
  final Dio _client = Dio(BaseOptions(
      validateStatus: validateStatus,
      baseUrl: appConfig.baseUrl,
      receiveDataWhenStatusError: true,
      contentType: "application/json"));

  static DataRepository get i => _instance;
  static final DataRepository _instance = DataRepository._private();

  DataRepository._private() {
    _client.interceptors.add(AuthenticationInterceptor());
    _client.interceptors.add(LoggingInterceptor());
  }

  Future<Response> updateDevice(BaseDeviceInfo deviceInfo) async {
    try {
      final response =
          await _client.put(APIConstants.updateDevice, data: deviceInfo.data);
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
}
