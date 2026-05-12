import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rota_em_flutter/core/routes/app_router.dart';
import 'package:rota_em_flutter/core/theme/app_theme.dart';
import 'package:rota_em_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rota_em_flutter/features/motorista/presentation/viewmodels/motorista_dashboard_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MotoristaDashboardViewmodel()),
        // Adicionar outros providers aqui
      ],
      child: MaterialApp.router(
        title: 'Rota em Flutter',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
