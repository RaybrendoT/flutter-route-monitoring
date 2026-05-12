import 'package:rota_em_flutter/core/network/dio_client.dart';
import 'package:rota_em_flutter/core/network/token_storage.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User?> login(String email, String password);
  Future<User?> register(String name, String email, String password);
  Future<String?> requestPasswordReset(Map<String, dynamic> identifier);
  Future<bool> verifyPasswordReset(Map<String, dynamic> identifier, String code);
  Future<bool> resetPassword(Map<String, dynamic> identifier, String code, String newPassword);
  Future<bool> verifyToken(String token);
  Future<bool> refreshToken();
  Future<bool> changePassword(String currentPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSourceImpl({DioClient? dioClient, TokenStorage? tokenStorage})
      : dioClient = dioClient ?? DioClient(),
        tokenStorage = tokenStorage ?? TokenStorage();

  @override
  Future<User?> login(String email, String password) async {
    final body = {
      'email': email,
      'password': password,
    };

    final response = await dioClient.dio.post('/auth/login/', data: body);
    final json = response.data as Map<String, dynamic>;
    final user = User.fromAuthResponse(json);

    if (user.accessToken != null && user.refreshToken != null) {
      await tokenStorage.saveTokens(
        accessToken: user.accessToken!,
        refreshToken: user.refreshToken!,
      );
    }

    return user;
  }

  @override
  Future<User?> register(String name, String email, String password) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
    };

    final response = await dioClient.dio.post('/auth/register/', data: body);
    final json = response.data as Map<String, dynamic>;
    final user = User.fromAuthResponse(json);

    if (user.accessToken != null && user.refreshToken != null) {
      await tokenStorage.saveTokens(
        accessToken: user.accessToken!,
        refreshToken: user.refreshToken!,
      );
    }

    return user;
  }

  @override
  Future<String?> requestPasswordReset(Map<String, dynamic> identifier) async {
    final response = await dioClient.dio.post('/auth/password-reset/request/', data: identifier);
    final json = response.data as Map<String, dynamic>;
    return json['verificationCode'] as String?;
  }

  @override
  Future<bool> verifyPasswordReset(Map<String, dynamic> identifier, String code) async {
    final body = Map<String, dynamic>.from(identifier);
    body['code'] = code;

    final response = await dioClient.dio.post('/auth/password-reset/verify/', data: body);
    final json = response.data as Map<String, dynamic>;
    return json['valid'] == true;
  }

  @override
  Future<bool> resetPassword(Map<String, dynamic> identifier, String code, String newPassword) async {
    final body = Map<String, dynamic>.from(identifier);
    body['code'] = code;
    body['new_password'] = newPassword;

    final response = await dioClient.dio.post('/auth/password-reset/reset/', data: body);
    final json = response.data as Map<String, dynamic>;
    return response.statusCode == 200 && json['status'] == 'ok';
  }

  @override
  Future<bool> verifyToken(String token) async {
    final response = await dioClient.dio.post('/auth/verify/', data: {'token': token});
    return response.statusCode == 200;
  }

  @override
  Future<bool> refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final response = await dioClient.dio.post('/auth/refresh/', data: {'refresh': refreshToken});
    final json = response.data as Map<String, dynamic>;
    final accessToken = json['access_token'] as String? ?? json['access'] as String?;
    final refresh = json['refresh_token'] as String? ?? json['refresh'] as String?;

    if (accessToken == null) return false;

    await tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refresh ?? refreshToken,
    );

    return true;
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final response = await dioClient.dio.post(
      '/auth/change-password/',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    if (response.statusCode == 200) {
      final json = response.data as Map<String, dynamic>;
      final accessToken = json['access_token'] as String? ?? json['access'] as String?;
      final refresh = json['refresh_token'] as String? ?? json['refresh'] as String?;

      if (accessToken != null) {
        await tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refresh ?? await tokenStorage.getRefreshToken() ?? '',
        );
      }

      return true;
    }

    return false;
  }
}
