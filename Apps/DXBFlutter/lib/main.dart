import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
    ),
  );
  runApp(const ProviderScope(child: DXBConnectApp()));
}

class DXBConnectApp extends ConsumerStatefulWidget {
  const DXBConnectApp({super.key});

  @override
  ConsumerState<DXBConnectApp> createState() => _DXBConnectAppState();
}

class _DXBConnectAppState extends ConsumerState<DXBConnectApp> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('[App] initState — launching auth check');
    Future.microtask(() async {
      try {
        await ref.read(authProvider.notifier).checkAuth();
      } catch (e) {
        if (kDebugMode) debugPrint('[App] Auth check error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(
      title: 'DXB Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
