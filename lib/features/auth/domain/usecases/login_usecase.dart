import '../entities/user.dart';
import '../../data/repositories/auth_repository.dart';

abstract class LoginUseCase {
  Future<User?> execute(String email, String password);
}

class LoginUseCaseImpl implements LoginUseCase {
  final AuthRepository repository;

  LoginUseCaseImpl(this.repository);

  @override
  Future<User?> execute(String email, String password) async {
    return await repository.login(email, password);
  }
}