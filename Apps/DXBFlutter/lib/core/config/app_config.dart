enum AppEnvironment { development, staging, production }

class AppConfig {
  static AppEnvironment current = AppEnvironment.production;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.development:
        return 'http://localhost:4000/api';
      case AppEnvironment.staging:
        return 'https://dxb-connect-staging.railway.app/api';
      case AppEnvironment.production:
        return 'https://web-production-14c51.up.railway.app/api';
    }
  }

  static String get stripePublishableKey {
    switch (current) {
      case AppEnvironment.development:
      case AppEnvironment.staging:
        return const String.fromEnvironment(
          'STRIPE_PK',
          defaultValue: 'pk_test_placeholder',
        );
      case AppEnvironment.production:
        return const String.fromEnvironment(
          'STRIPE_PK',
          defaultValue: 'pk_live_51T1yInErTYHH9DtVYXyZTKvRuPChIyf2HHzcSALBcDnrkkrgOatesY8l5JkS6Lv1CD5BDohjVXBcVIsKzY1ZuIoo009GNhy4pf',
        );
    }
  }

  static const String appName = 'DXB Connect';
  static const String merchantId = 'merchant.com.dxbconnect.app';
  static const String countryCode = 'AE';
  static const String currencyCode = 'USD';
  static const String keychainService = 'com.dxbconnect.app';
}
