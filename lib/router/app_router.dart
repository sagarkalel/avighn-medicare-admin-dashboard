import 'package:avighn_medicare/blocs/auth/auth_cubit.dart';
import 'package:avighn_medicare/screens/add_edit_product_screen.dart';
import 'package:avighn_medicare/screens/dashboard_shell.dart';
import 'package:avighn_medicare/screens/login_screen.dart';
import 'package:avighn_medicare/screens/product_detail_screen.dart';
import 'package:avighn_medicare/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthCubit _authCubit;
  AppRouter(this._authCubit);

  late final GoRouter router = GoRouter(
    initialLocation: '/products',
    redirect: (context, state) {
      final s = _authCubit.state;
      final isLogin = state.matchedLocation == '/login';
      if (s is AuthLoading || s is AuthInitial) return null;
      if (s is AuthUnauthenticated || s is AuthError)
        return isLogin ? null : '/login';
      if (s is AuthAuthenticated && isLogin) return '/products';
      return null;
    },
    refreshListenable: _GoRouterRefreshStream(_authCubit.stream),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (ctx, s) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (ctx, s, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (ctx, s) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/products/add',
            name: 'add-product',
            builder: (ctx, s) => const AddEditProductScreen(),
          ),
          GoRoute(
            path: '/products/:id',
            name: 'product-detail',
            builder: (ctx, s) =>
                ProductDetailScreen(productId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: '/products/:id/edit',
            name: 'edit-product',
            builder: (ctx, s) =>
                AddEditProductScreen(productId: s.pathParameters['id']),
          ),
        ],
      ),
    ],
    errorBuilder: (ctx, s) =>
        Scaffold(body: Center(child: Text('Page not found: ${s.error}'))),
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }
  late final dynamic _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
