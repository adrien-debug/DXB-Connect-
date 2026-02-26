import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/auth_storage.dart';
import '../api/api_client.dart';

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final authStorage = ref.read(authStorageProvider);
  return ApiClient(authStorage);
});
