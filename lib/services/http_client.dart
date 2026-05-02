import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}

Dio buildDio() {
  final baseUrl = dotenv.maybeGet('API_BASE_URL') ?? '';
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.interceptors.add(AuthInterceptor());
  return dio;
}
