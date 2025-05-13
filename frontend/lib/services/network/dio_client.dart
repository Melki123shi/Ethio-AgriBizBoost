// import 'package:app/services/token_storage.dart';
// import 'package:dio/dio.dart';

// class DioClient {
//   DioClient._();

//   static Dio? _dio;

//   static Dio getDio() => _dio ??= _buildDio();

//   static Dio _buildDio() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://ethio-agribizboost.onrender.com',
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 10),
//         followRedirects: true,
//         validateStatus: (code) => code != null && code < 500,
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (opts, handler) async {
//           final access = await TokenStorage.readAccessToken();
//           if (access != null && access.isNotEmpty) {
//             opts.headers['Authorization'] = 'Bearer $access';
//           }
//           return handler.next(opts);
//         },
//         onError: (err, handler) async {
//           final options = err.requestOptions;
//           if (err.response?.statusCode == 401 &&
//               options.extra['retry'] != true) {
//             final didRefresh = await _refreshToken();
//             if (didRefresh) {
//               final newAccess = await TokenStorage.readAccessToken();
//               if (newAccess != null && newAccess.isNotEmpty) {
//                 options.extra['retry'] = true;
//                 options.headers['Authorization'] = 'Bearer $newAccess';
//                 try {
//                   final response = await dio.fetch(options);
//                   return handler.resolve(response);
//                 } catch (e) {}
//               }
//             }
//           }
//           return handler.next(err);
//         },
//       ),
//     );

//     dio.interceptors.add(LogInterceptor(
//       requestBody: false,
//       responseBody: false,
//     ));

//     return dio;
//   }

//   static Future<bool> _refreshToken() async {
//     final refresh = await TokenStorage.readRefreshToken();
//     if (refresh == null || refresh.isEmpty) return false;

//     try {
//       final res = await getDio().post(
//         '/auth/refresh',
//         data: {'refreshToken': refresh},
//       );

//       if (res.statusCode != 200) return false;

//       final newAccess = res.data['access_token'] as String?;
//       final newRefresh = res.data['refresh_token'] as String?;
//       final type = res.data['token_type'] as String?;

//       if (newAccess == null || newAccess.isEmpty) {
//         return false;
//       }

//       await TokenStorage.saveAccessToken(newAccess);
//       if (newRefresh != null && newRefresh.isNotEmpty) {
//         await TokenStorage.saveRefreshToken(newRefresh);
//       }
//       if (type != null && type.isNotEmpty) {
//         await TokenStorage.saveTokenType(type);
//       }

//       return true;
//     } catch (_) {
//       return false;
//     }
//   }
// }


import 'package:dio/dio.dart';
import 'package:app/services/token_storage.dart';

class DioClient {
  DioClient._();

  static Dio? _dio;

  static Dio getDio() => _dio ??= _buildDio();

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://ethio-agribizboost.onrender.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: true,
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await TokenStorage.readAccessToken();
          print('→ REQUEST → [${options.method}] ${options.uri}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Body: ${options.data}');
          }
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
            print('Added Authorization header');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('← RESPONSE ← [${response.statusCode}] ${response.requestOptions.uri}');
          print('Response headers: ${response.headers.map}');
          print('Response data: ${response.data}');
          handler.next(response);
        },
        onError: (err, handler) async {
          print('‼ ERROR ‼ [${err.response?.statusCode}] ${err.requestOptions.method} ${err.requestOptions.uri}');
          print('Error message: ${err.message}');
          print('Error data: ${err.response?.data}');
          final options = err.requestOptions;
          if (err.response?.statusCode == 401 && options.extra['retry'] != true) {
            print('Attempting token refresh...');
            final didRefresh = await _refreshToken();
            if (didRefresh) {
              final newAccess = await TokenStorage.readAccessToken();
              if (newAccess != null && newAccess.isNotEmpty) {
                print('Token refreshed, retrying request...');
                options.headers['Authorization'] = 'Bearer $newAccess';
                options.extra['retry'] = true;
                try {
                  final cloned = await dio.fetch(options);
                  return handler.resolve(cloned);
                } catch (e) {
                  print('Retry failed: $e');
                }
              }
            } else {
              print('Refresh token failed');
            }
          }
          handler.next(err);
        },
      ),
    );

    // Detailed network logging
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
    print('🔄 Refreshing token...');
    final refresh = await TokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      print('No refresh token available');
      return false;
    }
    try {
      final res = await getDio().post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      print('Refresh response: ${res.statusCode} ${res.data}');
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
      print('Token refresh successful');
      return true;
    } catch (e) {
      print('Exception during refresh: $e');
      return false;
    }
  }
}
