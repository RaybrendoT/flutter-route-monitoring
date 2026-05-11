import '../entities/user.dart';
import '../../data/repositories/auth_repository.dart';

abstract class RegisterUseCase {
  Future<User?> execute(String name, String email, String password);
}

class RegisterUseCaseImpl implements RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCaseImpl(this.repository);

  @override
  Future<User?> execute(String name, String email, String password) async {
    return await repository.register(name, email, password);
  }
}