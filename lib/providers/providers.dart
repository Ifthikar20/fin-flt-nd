import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/deal_service.dart';
import '../services/favorites_service.dart';
import '../services/alert_service.dart';
import '../services/storyboard_service.dart';

// ─── Core Services ───────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

final dealServiceProvider = Provider<DealService>((ref) {
  return DealService(ref.read(apiClientProvider));
});

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService(ref.read(apiClientProvider));
});

final alertServiceProvider = Provider<AlertService>((ref) {
  return AlertService(ref.read(apiClientProvider));
});

final storyboardServiceProvider = Provider<StoryboardService>((ref) {
  return StoryboardService(ref.read(apiClientProvider));
});

// ─── Auth State ──────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final UserPreferences? preferences;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.preferences,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserPreferences? preferences,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      preferences: preferences ?? this.preferences,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    state = state.copyWith(
      status: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        preferences: response.preferences,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  Future<void> register(String email, String password,
      {String? firstName, String? lastName}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        preferences: response.preferences,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _authService.signInWithGoogle();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        preferences: response.preferences,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _authService.signInWithApple();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        preferences: response.preferences,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _extractError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('error')) {
        return msg.replaceAll('Exception: ', '');
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
