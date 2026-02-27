import 'package:flutter/foundation.dart';
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
    final sw = Stopwatch()..start();
    state = state.copyWith(status: AuthState.loading);
    try {
      final hasTokens = await _authStorage.hasTokens().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          if (kDebugMode) debugPrint('[Auth] hasTokens timeout, assuming no tokens');
          return false;
        },
      );
      if (kDebugMode) debugPrint('[Auth] hasTokens: $hasTokens (${sw.elapsedMilliseconds}ms)');
      if (!hasTokens) {
        state = state.copyWith(status: AuthState.unauthenticated);
        return;
      }

      final userId = await _authStorage.getUserId().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
      final email = await _authStorage.getUserEmail().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
      final name = await _authStorage.getUserName().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );

      if (userId != null && email != null) {
        state = state.copyWith(
          status: AuthState.authenticated,
          user: UserInfo(id: userId, email: email, name: name),
        );
        if (kDebugMode) debugPrint('[Auth] Authenticated from local tokens (${sw.elapsedMilliseconds}ms)');

        _validateTokenRemotely();
      } else {
        await _authStorage.clearTokens();
        state = state.copyWith(status: AuthState.unauthenticated);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] checkAuth error: $e');
      try {
        await _authStorage.clearTokens().timeout(const Duration(milliseconds: 500));
      } catch (clearError) {
        if (kDebugMode) debugPrint('[Auth] clearTokens error: $clearError');
      }
      state = state.copyWith(status: AuthState.unauthenticated);
    }
  }

  Future<void> _validateTokenRemotely() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.health);
      if (response.statusCode != 200) {
        if (kDebugMode) debugPrint('[Auth] Remote validation failed, logging out');
        await _authStorage.clearTokens();
        if (mounted) state = state.copyWith(status: AuthState.unauthenticated, user: null);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] Remote validation error (user stays logged in): $e');
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
    return ApiClient.extractErrorMessage(e, 'An unexpected error occurred');
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
