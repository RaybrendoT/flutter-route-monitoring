import 'package:dio/dio.dart';
import 'package:rota_em_flutter/core/network/auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:8000/api',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(AuthInterceptor(dio: dio));
  }
}
