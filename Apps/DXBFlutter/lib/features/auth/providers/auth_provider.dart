import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/auth_storage.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../models/auth_models.dart';

class AuthNotifier extends StateNotifier<AuthStateData> {
  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  AuthNotifier(this._apiClient, this._authStorage)
      : super(const AuthStateData());

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthState.loading);
    try {
      final hasTokens = await _authStorage.hasTokens();
      if (!hasTokens) {
        state = state.copyWith(status: AuthState.unauthenticated);
        return;
      }

      final response = await _apiClient.get(ApiEndpoints.esimOrders);
      if (response.statusCode == 200) {
        final userId = await _authStorage.getUserId();
        final email = await _authStorage.getUserEmail();
        final name = await _authStorage.getUserName();
        state = state.copyWith(
          status: AuthState.authenticated,
          user: userId != null && email != null
              ? UserInfo(id: userId, email: email, name: name)
              : null,
        );
      } else {
        await _authStorage.clearTokens();
        state = state.copyWith(status: AuthState.unauthenticated);
      }
    } catch (_) {
      await _authStorage.clearTokens();
      state = state.copyWith(status: AuthState.unauthenticated);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthState.loading, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );
      await _handleAuthResponse(response.data);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        error: _extractError(e),
      );
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(status: AuthState.loading, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: {'email': email, 'password': password, 'name': name},
      );
      await _handleAuthResponse(response.data);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        error: _extractError(e),
      );
    }
  }

  Future<void> sendOtp(String email) async {
    state = state.copyWith(status: AuthState.loading, error: null);
    try {
      await _apiClient.post(
        ApiEndpoints.authSendOtp,
        data: {'email': email},
      );
      state = state.copyWith(status: AuthState.unauthenticated, error: null);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        error: _extractError(e),
      );
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = state.copyWith(status: AuthState.loading, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authVerifyOtp,
        data: {'email': email, 'otp': otp},
      );
      await _handleAuthResponse(response.data);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        error: _extractError(e),
      );
    }
  }

  Future<void> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? name,
  }) async {
    state = state.copyWith(status: AuthState.loading, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authApple,
        data: {
          'identityToken': identityToken,
          'authorizationCode': authorizationCode,
          if (email != null) 'email': email,
          if (name != null) 'name': name,
        },
      );
      await _handleAuthResponse(response.data);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        error: _extractError(e),
      );
    }
  }

  Future<void> signOut() async {
    await _authStorage.clearTokens();
    state = const AuthStateData(status: AuthState.unauthenticated);
  }

  Future<void> _handleAuthResponse(dynamic data) async {
    final authResponse = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _authStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    await _authStorage.saveUser(
      id: authResponse.user.id,
      email: authResponse.user.email,
      name: authResponse.user.name,
    );
    state = state.copyWith(
      status: AuthState.authenticated,
      user: authResponse.user,
      error: null,
    );
  }

  String _extractError(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}

class AuthStateData {
  final AuthState status;
  final UserInfo? user;
  final String? error;

  const AuthStateData({
    this.status = AuthState.initial,
    this.user,
    this.error,
  });

  AuthStateData copyWith({
    AuthState? status,
    UserInfo? user,
    String? error,
  }) {
    return AuthStateData(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthState.authenticated;
  bool get isLoading => status == AuthState.loading;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final authStorage = ref.read(authStorageProvider);
  return AuthNotifier(apiClient, authStorage);
});
