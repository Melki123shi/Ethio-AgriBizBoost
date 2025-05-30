import 'package:dio/dio.dart';
import 'package:app/services/token_storage.dart';

class DioClient {
  DioClient._();

  static Dio? _dio;

  static Dio getDio() => _dio ??= _buildDio();

  // Reset singleton for testing
  static void resetForTesting() {
    _dio = null;
  }

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://ethio-agribizboost.onrender.com',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        persistentConnection: false,
        followRedirects: true,
        validateStatus: (_) => true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await TokenStorage.readAccessToken();
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          if (response.statusCode == 401 &&
              response.requestOptions.extra['retry'] != true) {
            final didRefresh = await _refreshToken();
            if (didRefresh) {
              final newAccess = await TokenStorage.readAccessToken();
              if (newAccess != null && newAccess.isNotEmpty) {
                final opts = response.requestOptions;

                final clonedResponse = await dio.request(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(
                    method: opts.method,
                    headers: {
                      ...opts.headers,
                      'Authorization': 'Bearer $newAccess',
                    },
                    contentType: opts.contentType,
                    responseType: opts.responseType,
                    extra: {
                      ...opts.extra,
                      'retry': true,
                    },
                  ),
                );
                return handler.resolve(clonedResponse);
              }
            } else {}
          }

          handler.next(response);
        },
        onError: (err, handler) async {
          handler.next(err);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  static Future<bool> _refreshToken() async {
    final refresh = await TokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      return false;
    }
    try {
      final plainDio =
          Dio(BaseOptions(baseUrl: 'https://ethio-agribizboost.onrender.com'));
      final res = await plainDio.post(
        '/auth/refresh',
        data: {"refresh_token": refresh},
      );

      if (res.statusCode != 200) return false;

      final newAccess = res.data['access_token'] as String?;
      final newRefresh = res.data['refresh_token'] as String?;
      final type = res.data['token_type'] as String?;

      if (newAccess == null || newAccess.isEmpty) return false;

      await TokenStorage.saveAccessToken(newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await TokenStorage.saveRefreshToken(newRefresh);
      }
      if (type != null && type.isNotEmpty) {
        await TokenStorage.saveTokenType(type);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
