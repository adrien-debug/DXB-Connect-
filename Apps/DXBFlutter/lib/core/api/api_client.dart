import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/api_endpoints.dart';
import 'auth_storage.dart';

class ApiClient {
  late final Dio _dio;
  final AuthStorage _authStorage;

  ApiClient(this._authStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'Flutter',
          'X-Client-Version': '1.0.0',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final retryResponse = await _retry(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _authStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(
        BaseOptions(baseUrl: AppConfig.baseUrl),
      ).post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        await _authStorage.saveTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (_) {
      await _authStorage.clearTokens();
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _authStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => _dio.post<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) => _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
  }) => _dio.delete<T>(path, data: data);
}
