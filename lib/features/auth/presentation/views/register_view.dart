import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rota_em_flutter/shared/widgets/custom_button.dart';
import 'package:rota_em_flutter/shared/widgets/custom_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _nameController,
              hintText: 'Nome completo',
            ),
            const SizedBox(height: 16),
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
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirmar senha',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Cadastrar',
              onPressed: () async {
                if (_passwordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senhas não coincidem')),
                  );
                  return;
                }
                await authViewModel.register(
                  _nameController.text,
                  _emailController.text,
                  _passwordController.text,
                );

                final currentUser = authViewModel.currentUser;
                final errorMessage = authViewModel.errorMessage;
                if (!mounted) return;

                final router = GoRouter.of(context);
                final messenger = ScaffoldMessenger.of(context);

                if (currentUser != null) {
                  router.go('/login');
                } else if (errorMessage != null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}