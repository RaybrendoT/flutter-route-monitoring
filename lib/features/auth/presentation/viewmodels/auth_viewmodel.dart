import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository = AuthRepositoryImpl();
  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;

  AuthViewModel() {
    loginUseCase = LoginUseCaseImpl(authRepository);
    registerUseCase = RegisterUseCaseImpl(authRepository);
  }

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get requiresPasswordChange => _currentUser?.mustChangePassword ?? false;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await loginUseCase.execute(email, password);
      if (_currentUser == null) {
        _errorMessage = 'Credenciais inválidas';
      }
    } catch (e) {
      _errorMessage = 'Erro ao fazer login';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await registerUseCase.execute(name, email, password);
    } catch (e) {
      _errorMessage = 'Erro ao registrar';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}