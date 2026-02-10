import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthAppleSignInRequested>(_onAppleSignIn);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      emit(AuthAuthenticated(
        user: User(id: '', email: ''),
        preferences: UserPreferences(),
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(
        user: response.user,
        preferences: response.preferences,
      ));
    } catch (e) {
      debugPrint('Login error: $e');
      emit(AuthFailure(_extractError(e)));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(AuthAuthenticated(
        user: response.user,
        preferences: response.preferences,
      ));
    } catch (e) {
      debugPrint('Register error: $e');
      emit(AuthFailure(_extractError(e)));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.signInWithGoogle();
      emit(AuthAuthenticated(
        user: response.user,
        preferences: response.preferences,
      ));
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      emit(AuthFailure(_extractError(e)));
    }
  }

  Future<void> _onAppleSignIn(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.signInWithApple();
      emit(AuthAuthenticated(
        user: response.user,
        preferences: response.preferences,
      ));
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      emit(AuthFailure(_extractError(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }

  String _extractError(dynamic e) {
    // Dio HTTP errors — extract the server's error message
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        // Common Django REST error formats
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('non_field_errors')) {
          final errors = data['non_field_errors'];
          if (errors is List && errors.isNotEmpty) return errors.first.toString();
        }
        // Field-level errors (e.g. {"email": ["This field is required."]})
        final fieldErrors = <String>[];
        data.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors.add('${_capitalize(key.toString())}: ${value.first}');
          } else if (value is String) {
            fieldErrors.add(value);
          }
        });
        if (fieldErrors.isNotEmpty) return fieldErrors.join('\n');
      }
      if (data is String && data.isNotEmpty) return data;
    }

    // Dio connection / timeout errors
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Please check your internet.';
        default:
          return e.message ?? 'Network error. Please try again.';
      }
    }

    // Generic exception
    final msg = e.toString();
    if (msg.contains('Exception: ')) {
      return msg.replaceAll('Exception: ', '');
    }
    return 'Something went wrong. Please try again.';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

