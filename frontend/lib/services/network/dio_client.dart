import 'package:dio/dio.dart';

class DioClient {
  static Dio getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.2:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: true,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       options.headers['Authorization'] = 'Bearer your_token';
    //       return handler.next(options);
    //     },
    //     onResponse: (response, handler) {
    //       return handler.next(response);
    //     },
    //     onError: (DioException e, handler) {
    //       return handler.next(e);
    //     },
    //   ),
    // );

    return dio;
  }
}
