import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:avighn_medicare/repositories/auth_repository.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(AuthInitial()) { _checkSession(); }

  Future<void> _checkSession() async {
    emit(AuthLoading());
    emit(await _repo.isLoggedIn() ? AuthAuthenticated() : AuthUnauthenticated());
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      emit(await _repo.login(username, password) ? AuthAuthenticated() : const AuthError('Invalid username or password.'));
    } catch (e) { emit(AuthError(e.toString())); }
  }

  Future<void> logout() async { await _repo.logout(); emit(AuthUnauthenticated()); }
}
