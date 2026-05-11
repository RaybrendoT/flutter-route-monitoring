import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rota_em_flutter/shared/widgets/custom_button.dart';
import 'package:rota_em_flutter/shared/widgets/custom_text_field.dart';
import '../../domain/entities/user.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _emailController,
              hintText: 'Email',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Senha',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Entrar',
              onPressed: () async {
                await authViewModel.login(
                  _emailController.text,
                  _passwordController.text,
                );

                final user = authViewModel.currentUser;
                final errorMessage = authViewModel.errorMessage;
                if (!mounted) return;

                if (!mounted) return;
                final router = GoRouter.of(context);
                final messenger = ScaffoldMessenger.of(context);

                if (user != null) {
                  if (user.userType == UserType.motorista) {
                    router.go('/motorista-dashboard');
                  } else {
                    router.go('/colaborador-dashboard');
                  }
                } else if (errorMessage != null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Não possui cadastro? Registre-se'),
            ),
          ],
        ),
      ),
    );
  }
}