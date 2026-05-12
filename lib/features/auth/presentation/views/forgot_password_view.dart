import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  int currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationCode;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  Map<String, dynamic> _buildIdentifier() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final identifier = <String, dynamic>{};

    if (email.isNotEmpty) {
      identifier['email'] = email;
    } else if (phone.isNotEmpty) {
      identifier['phone'] = phone;
    }

    return identifier;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\-]+\.[A-Za-z]{2,}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final normalizedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return normalizedPhone.isNotEmpty && RegExp(r'^\+?[0-9]{8,15}$').hasMatch(normalizedPhone);
  }

  bool _validatePassword(String password) {
    if (password.length < 8) return false;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'''[!@#\$&*~\^()\[\]{}\-_+=|\\:;"'<>,.?/]''').hasMatch(password);
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  Future<void> _submitRequest(AuthViewModel authViewModel) async {
    final identifier = _buildIdentifier();
    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = 'Informe seu e-mail ou telefone';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (identifier.containsKey('email') && !_isValidEmail(identifier['email'] as String)) {
      setState(() {
        _errorMessage = 'Informe um e-mail válido';
        _isLoading = false;
      });
      return;
    }

    if (identifier.containsKey('phone') && !_isValidPhone(identifier['phone'] as String)) {
      setState(() {
        _errorMessage = 'Informe um telefone válido';
        _isLoading = false;
      });
      return;
    }

    final verificationCode = await authViewModel.requestPasswordReset(
      email: identifier['email'] as String?,
      phone: identifier['phone'] as String?,
    );

    setState(() {
      _isLoading = false;
      _verificationCode = verificationCode;
    });

    if (verificationCode == null && authViewModel.errorMessage != null) {
      setState(() {
        _errorMessage = authViewModel.errorMessage;
      });
      return;
    }

    nextStep();
  }

  Future<void> _submitVerify(AuthViewModel authViewModel) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Informe o código de verificação';
      });
      return;
    }

    final identifier = _buildIdentifier();
    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = 'Informe seu e-mail ou telefone';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (identifier.containsKey('email') && !_isValidEmail(identifier['email'] as String)) {
      setState(() {
        _errorMessage = 'Informe um e-mail válido';
        _isLoading = false;
      });
      return;
    }

    if (identifier.containsKey('phone') && !_isValidPhone(identifier['phone'] as String)) {
      setState(() {
        _errorMessage = 'Informe um telefone válido';
        _isLoading = false;
      });
      return;
    }

    final valid = await authViewModel.verifyPasswordReset(
      email: identifier['email'] as String?,
      phone: identifier['phone'] as String?,
      code: code,
    );

    setState(() {
      _isLoading = false;
      if (!valid) {
        _errorMessage = authViewModel.errorMessage ?? 'Código inválido';
      }
    });

    if (valid) {
      nextStep();
    }
  }

  Future<void> _submitReset(AuthViewModel authViewModel) async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha a nova senha e a confirmação';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'As senhas não coincidem';
      });
      return;
    }

    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Informe o código de verificação';
      });
      return;
    }

    final identifier = _buildIdentifier();
    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = 'Informe seu e-mail ou telefone';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_validatePassword(newPassword)) {
      setState(() {
        _errorMessage = 'A senha deve ter ao menos 8 caracteres, incluir letra maiúscula, minúscula, número e caractere especial';
        _isLoading = false;
      });
      return;
    }

    if (identifier.containsKey('email') && !_isValidEmail(identifier['email'] as String)) {
      setState(() {
        _errorMessage = 'Informe um e-mail válido';
        _isLoading = false;
      });
      return;
    }

    if (identifier.containsKey('phone') && !_isValidPhone(identifier['phone'] as String)) {
      setState(() {
        _errorMessage = 'Informe um telefone válido';
        _isLoading = false;
      });
      return;
    }

    final updated = await authViewModel.resetPassword(
      email: identifier['email'] as String?,
      phone: identifier['phone'] as String?,
      code: code,
      newPassword: newPassword,
    );

    setState(() {
      _isLoading = false;
      if (!updated) {
        _errorMessage = authViewModel.errorMessage ?? 'Falha ao redefinir senha';
      }
    });

    if (updated) {
      nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    Widget screen;

    switch (currentStep) {
      case 0:
        screen = IdentifyStep(
          emailController: _emailController,
          phoneController: _phoneController,
          onSubmit: () => _submitRequest(authViewModel),
          isLoading: _isLoading,
          errorMessage: _errorMessage,
        );
        break;
      case 1:
        screen = VerifyCodeStep(
          codeController: _codeController,
          verificationCode: _verificationCode,
          onSubmit: () => _submitVerify(authViewModel),
          onBack: previousStep,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
        );
        break;
      case 2:
        screen = CreatePasswordStep(
          newPasswordController: _newPasswordController,
          confirmPasswordController: _confirmPasswordController,
          onSubmit: () => _submitReset(authViewModel),
          onBack: previousStep,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
        );
        break;
      default:
        screen = SuccessStep(onFinish: () => GoRouter.of(context).go('/login'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020B1A),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: screen,
        ),
      ),
    );
  }
}

class IdentifyStep extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;

  const IdentifyStep({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.onSubmit,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Recuperar acesso',
                style: TextStyle(
                  color: Color(0xFF1E90FF),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Informe seu e-mail corporativo ou telefone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 45),
              customInput(
                controller: emailController,
                hint: 'E-mail corporativo',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              customInput(
                controller: phoneController,
                hint: 'Telefone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              primaryButton(
                text: isLoading ? 'Aguarde...' : 'Continuar',
                onPressed: isLoading ? null : onSubmit,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              const Text(
                'Você receberá um código\npara redefinir sua senha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyCodeStep extends StatelessWidget {
  final TextEditingController codeController;
  final String? verificationCode;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool isLoading;
  final String? errorMessage;

  const VerifyCodeStep({
    super.key,
    required this.codeController,
    required this.verificationCode,
    required this.onSubmit,
    required this.onBack,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Confirme seu e-mail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E90FF),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Digite o código recebido',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              if (verificationCode != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Código de demo: $verificationCode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1E90FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              customInput(
                controller: codeController,
                hint: 'Código de verificação',
                icon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(height: 35),
              primaryButton(
                text: isLoading ? 'Validando...' : 'Verificar',
                onPressed: isLoading ? null : onSubmit,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: onBack,
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              const Text(
                'Não recebeu? Reenvie o código no backend ou tente novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class CreatePasswordStep extends StatelessWidget {
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool isLoading;
  final String? errorMessage;

  const CreatePasswordStep({
    super.key,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onBack,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Criar nova senha',
                style: TextStyle(
                  color: Color(0xFF1E90FF),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Defina sua nova senha',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              customInput(
                controller: newPasswordController,
                hint: 'Nova senha',
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 18),
              customInput(
                controller: confirmPasswordController,
                hint: 'Confirmar senha',
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Força da senha: Média',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              primaryButton(
                text: isLoading ? 'Salvando...' : 'Salvar senha',
                onPressed: isLoading ? null : onSubmit,
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              TextButton(
                onPressed: onBack,
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessStep extends StatelessWidget {
  final VoidCallback onFinish;

  const SuccessStep({
    super.key,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1E90FF).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF1E90FF),
                size: 70,
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              'Senha redefinida\ncom sucesso',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Sua conta já pode ser acessada\nnovamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 45),
            TextButton(
              onPressed: onFinish,
              child: const Text(
                'Voltar ao login',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customInput({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool obscure = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white54,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white38,
      ),
      suffixIcon: obscure
          ? const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.white38,
            )
          : null,
      filled: true,
      fillColor: const Color(0xFF13294B),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget primaryButton({
  required String text,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2EA7FF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}