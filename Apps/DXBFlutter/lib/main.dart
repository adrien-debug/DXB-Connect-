import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'features/auth/models/auth_models.dart';
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
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);

    if (authState.status == AuthState.initial ||
        authState.status == AuthState.loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'DXB Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_simpass.png',
              width: 200,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text(
                'SimPass',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
