import 'package:dio/dio.dart';
import 'package:rota_em_flutter/core/network/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor({required this.dio, TokenStorage? tokenStorage})
      : tokenStorage = tokenStorage ?? TokenStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken != null && options.headers['Authorization'] == null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing(err.requestOptions)) {
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          final opts = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          );
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: opts,
          );
          return handler.resolve(response);
        }
      } catch (_) {
        await tokenStorage.clearTokens();
      }
    }
    return handler.next(err);
  }

  bool _isRefreshing(RequestOptions requestOptions) {
    return requestOptions.path.contains('/auth/refresh/');
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await dio.post(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );

    final accessToken = response.data['access'] as String?;
    if (accessToken != null) {
      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    return accessToken;
  }
}
