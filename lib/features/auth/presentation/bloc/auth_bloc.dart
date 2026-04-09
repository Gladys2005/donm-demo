import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/services/storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final token = await StorageService.getAccessToken();
      final profile = await StorageService.getUserProfile();
      
      if (token != null && profile != null) {
        emit(AuthAuthenticated(
          user: profile,
          token: token,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _loginUseCase.call(
        LoginParams(
          email: event.email,
          password: event.password,
        ),
      );
      
      await StorageService.saveTokens(
        accessToken: result['access_token'],
        refreshToken: result['refresh_token'],
      );
      
      await StorageService.saveUserProfile(result['user']);
      
      if (event.rememberMe) {
        await StorageService.setBool('remember_me', true);
      }
      
      emit(AuthAuthenticated(
        user: result['user'],
        token: result['access_token'],
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _registerUseCase.call(
        RegisterParams(
          name: event.name ?? event.email,
          email: event.email,
          phone: event.phone,
          password: event.password,
          role: event.role ?? 'client',
        ),
      );
      
      await StorageService.saveTokens(
        accessToken: result['access_token'],
        refreshToken: result['refresh_token'],
      );
      
      await StorageService.saveUserProfile(result['user']);
      
      emit(AuthAuthenticated(
        user: result['user'],
        token: result['access_token'],
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _logoutUseCase.call(const NoParams());
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    await StorageService.clearTokens();
    await StorageService.clearUserProfile();
    await StorageService.setBool('remember_me', false);
    
    emit(AuthUnauthenticated());
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      
      if (refreshToken == null) {
        emit(AuthUnauthenticated());
        return;
      }
      
      // This would call the refresh token use case
      // For now, just emit unauthenticated
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
