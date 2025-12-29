import 'package:dio/dio.dart';

/// Простой retry-интерцептор без внешних пакетов
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> delays;

  _RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.delays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra['retry'] == true) {
      handler.reject(err); // уже retry – не циклим
      return;
    }
    int attempt = err.requestOptions.extra['attempt'] ?? 0;
    if (attempt < retries) {
      await Future.delayed(delays[attempt]);
      final options = err.requestOptions.copyWith(
        extra: {...err.requestOptions.extra, 'attempt': attempt + 1, 'retry': true},
      );
      try {
        final response = await dio.fetch(options);
        handler.resolve(response);
      } catch (e) {
        handler.reject(err);
      }
    } else {
      handler.reject(err);
    }
  }
}

/// Единый Dio-клиент с очисткой интерцепторов и retry
class ApiClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://edupeak.ru',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // защита от hot-restart
    dio.interceptors.clear();

    // логи (можно убрать в проде)
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    // retry
    dio.interceptors.add(_RetryInterceptor(dio: dio));

    return dio;
  }
}