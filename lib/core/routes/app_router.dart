import 'package:go_router/go_router.dart';
import 'package:rota_em_flutter/features/auth/presentation/views/login_view.dart';
import 'package:rota_em_flutter/features/auth/presentation/views/register_view.dart';
import 'package:rota_em_flutter/features/motorista/presentation/views/motorista_dashboard_view.dart';
import 'package:rota_em_flutter/features/colaborador/presentation/views/colaborador_dashboard_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/motorista-dashboard',
        builder: (context, state) => const MotoristaDashboardView(),
      ),
      GoRoute(
        path: '/colaborador-dashboard',
        builder: (context, state) => const ColaboradorDashboardView(),
      ),
    ],
  );
}