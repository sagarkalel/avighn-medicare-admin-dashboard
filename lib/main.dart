import 'package:avighn_medicare/blocs/auth/auth_cubit.dart';
import 'package:avighn_medicare/blocs/images/images_cubit.dart';
import 'package:avighn_medicare/blocs/products/products_cubit.dart';
import 'package:avighn_medicare/repositories/auth_repository.dart';
import 'package:avighn_medicare/repositories/image_repository.dart';
import 'package:avighn_medicare/repositories/product_repository.dart';
import 'package:avighn_medicare/router/app_router.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AvighnMedicareApp());
}

class AvighnMedicareApp extends StatelessWidget {
  const AvighnMedicareApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ProductRepository()),
        RepositoryProvider(create: (_) => ImageRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AuthCubit(ctx.read<AuthRepository>())),
          BlocProvider(
            create: (ctx) => ProductsCubit(ctx.read<ProductRepository>()),
          ),
          BlocProvider(
            create: (ctx) => ImagesCubit(ctx.read<ImageRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final router = AppRouter(context.read<AuthCubit>()).router;
            return MaterialApp.router(
              title: 'Avighn Medicare — Admin',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
