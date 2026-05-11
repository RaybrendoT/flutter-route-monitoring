import '../../domain/entities/user.dart';
import '../datasources/auth_remote_data_source.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> register(String name, String email, String password);
  Future<bool> verifyToken(String token);
  Future<bool> refreshToken();
  Future<bool> changePassword(String currentPassword, String newPassword);
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<User?> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<User?> register(String name, String email, String password) async {
    return await remoteDataSource.register(name, email, password);
  }

  @override
  Future<bool> verifyToken(String token) async {
    return await remoteDataSource.verifyToken(token);
  }

  @override
  Future<bool> refreshToken() async {
    return await remoteDataSource.refreshToken();
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    return await remoteDataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> logout() async {
    // Limpar token local, se necessário
  }
}