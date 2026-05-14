import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E90FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 25),

                // Título
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rota',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'certa',
                        style: TextStyle(
                          color: Color(0xFF1E90FF),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo
                const Text(
                  'transporte corporativo\ninteligente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 50),

                // Botão
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => GoRouter.of(context).go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EA7FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Vamos começar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Termos
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Ao entrar, você concorda com\nnossos\n',
                      ),
                      TextSpan(
                        text: 'Termos de Uso ',
                        style: TextStyle(
                          color: Color(0xFF2EA7FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: 'e '),
                      TextSpan(
                        text: 'Política de\nPrivacidade',
                        style: TextStyle(
                          color: Color(0xFF2EA7FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}