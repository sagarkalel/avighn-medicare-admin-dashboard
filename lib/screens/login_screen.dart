import 'package:avighn_medicare/blocs/auth/auth_cubit.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _u.dispose();
    _p.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(_u.text.trim(), _p.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (ctx, s) {
          if (s is AuthAuthenticated) ctx.go('/products');
          if (s is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(s.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width > 768)
              Expanded(flex: 5, child: _Brand()),
            Expanded(
              flex: 4,
              child: _LoginForm(
                formKey: _formKey,
                u: _u,
                p: _p,
                obscure: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                onSubmit: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF26A69A)],
      ),
    ),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                size: 36,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),
            const SizedBox(height: 32),
            const Text(
              'Avighn\nMedicare',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Text(
              'Manage your complete product\ncatalogue with ease.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.75),
                height: 1.7,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 48),
            ...[
              ('Catalogue Management', Icons.inventory_2_outlined),
              ('Real-time Stock Updates', Icons.sync_rounded),
              ('Image Gallery', Icons.photo_library_outlined),
            ].indexed.map(
              (e) =>
                  Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                e.$2.$2,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                e.$2.$1,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 500 + e.$1 * 100))
                      .slideX(begin: -0.1, end: 0),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController u, p;
  final bool obscure;
  final VoidCallback onToggleObscure, onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.u,
    required this.p,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext ctx) => Container(
    color: AppColors.surface,
    child: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(ctx).textTheme.headlineLarge,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your medicine catalogue',
                  style: Theme.of(ctx).textTheme.bodyLarge,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 40),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: u,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Enter username' : null,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: p,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: onToggleObscure,
                          ),
                        ),
                        onFieldSubmitted: (_) => onSubmit(),
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Enter password' : null,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (ctx, s) {
                          final loading = s is AuthLoading;
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : onSubmit,
                              child: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin access only. Contact store owner for credentials.',
                          style: TextStyle(fontSize: 12, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
