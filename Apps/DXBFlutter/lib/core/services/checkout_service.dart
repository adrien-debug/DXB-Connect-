import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../api/api_client.dart';
import '../config/api_endpoints.dart';
import '../config/app_config.dart';

class CheckoutResult {
  final bool success;
  final String? orderId;
  final String? orderNumber;
  final String? error;

  const CheckoutResult({
    required this.success,
    this.orderId,
    this.orderNumber,
    this.error,
  });
}

const _kBackground = Color(0xFF1A1A2E);
const _kPrimary = Color(0xFFD4FF00);
const _kComponentBg = Color(0xFF252545);
const _kComponentText = Color(0xFFFFFFFF);
const _kPlaceholder = Color(0xFF8E8E93);

SetupPaymentSheetParameters _sheetParams(String clientSecret) {
  return SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    merchantDisplayName: AppConfig.appName,
    style: ThemeMode.dark,
    appearance: const PaymentSheetAppearance(
      colors: PaymentSheetAppearanceColors(
        background: _kBackground,
        primary: _kPrimary,
        componentBackground: _kComponentBg,
        componentText: _kComponentText,
        placeholderText: _kPlaceholder,
      ),
      shapes: PaymentSheetShape(borderRadius: 16),
    ),
    applePay: const PaymentSheetApplePay(merchantCountryCode: 'AE'),
    googlePay: const PaymentSheetGooglePay(
      merchantCountryCode: 'AE',
      testEnv: false,
    ),
  );
}

class CheckoutService {
  final ApiClient _apiClient;

  CheckoutService(this._apiClient);

  /// Full checkout flow for eSIM purchase:
  /// 1. Create checkout + Stripe PaymentIntent on backend
  /// 2. Present Stripe Payment Sheet
  /// 3. Confirm payment on backend
  /// 4. Trigger eSIM purchase on backend
  Future<CheckoutResult> purchaseEsim({
    required String packageCode,
    required String packageName,
    required double price,
    required String customerEmail,
    required String customerName,
  }) async {
    try {
      final checkoutResponse = await _apiClient.post(
        ApiEndpoints.checkout,
        data: {
          'items': [
            {
              'product_id': null,
              'product_name': packageName,
              'product_sku': packageCode,
              'quantity': 1,
              'unit_price': price,
            }
          ],
          'payment_method': 'stripe',
          'customer_email': customerEmail,
          'customer_name': customerName,
        },
      );

      final checkoutData = checkoutResponse.data;
      if (checkoutData['success'] != true) {
        return CheckoutResult(
          success: false,
          error: checkoutData['error']?.toString() ?? 'Checkout failed',
        );
      }

      final clientSecret = checkoutData['payment']?['client_secret'] as String?;
      final paymentIntentId = checkoutData['payment']?['payment_intent_id'] as String?;
      final orderId = checkoutData['order']?['id']?.toString();
      final orderNumber = checkoutData['order']?['order_number']?.toString();

      if (clientSecret == null || paymentIntentId == null) {
        return const CheckoutResult(
          success: false,
          error: 'Payment initialization failed',
        );
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: _sheetParams(clientSecret),
      );
      await Stripe.instance.presentPaymentSheet();

      await _apiClient.post(
        ApiEndpoints.checkoutConfirm,
        data: {
          'order_id': orderId,
          'payment_intent_id': paymentIntentId,
        },
      );

      final purchaseResponse = await _apiClient.post(
        ApiEndpoints.esimPurchase,
        data: {'packageCode': packageCode},
      );

      final purchaseData = purchaseResponse.data;
      if (purchaseData['success'] != true) {
        return CheckoutResult(
          success: false,
          error: purchaseData['error']?.toString() ?? 'eSIM provisioning failed after payment',
        );
      }

      return CheckoutResult(
        success: true,
        orderId: orderId,
        orderNumber: orderNumber,
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const CheckoutResult(success: false, error: 'Payment cancelled');
      }
      if (kDebugMode) debugPrint('[Checkout] Stripe error: ${e.error.message}');
      return CheckoutResult(
        success: false,
        error: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Checkout] Error: $e');
      return CheckoutResult(
        success: false,
        error: ApiClient.extractErrorMessage(e, 'Purchase failed. Please try again.'),
      );
    }
  }

  /// Subscription checkout flow:
  /// Backend creates Stripe subscription with incomplete status,
  /// returns clientSecret for payment confirmation
  Future<CheckoutResult> createSubscription({
    required String plan,
    required String billingPeriod,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.subscriptionsCreate,
        data: {
          'plan': plan,
          'billing_period': billingPeriod,
        },
      );

      final data = response.data;
      if (data['success'] != true) {
        return CheckoutResult(
          success: false,
          error: data['error']?.toString() ?? 'Subscription creation failed',
        );
      }

      final clientSecret = data['clientSecret'] as String?;
      final subscriptionId = data['subscriptionId']?.toString();

      if (clientSecret == null) {
        return CheckoutResult(
          success: true,
          orderId: data['data']?['id']?.toString(),
        );
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: _sheetParams(clientSecret),
      );
      await Stripe.instance.presentPaymentSheet();

      return CheckoutResult(success: true, orderId: subscriptionId);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const CheckoutResult(success: false, error: 'Payment cancelled');
      }
      if (kDebugMode) debugPrint('[Subscription] Stripe error: ${e.error.message}');
      return CheckoutResult(
        success: false,
        error: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Subscription] Error: $e');
      return CheckoutResult(
        success: false,
        error: ApiClient.extractErrorMessage(e, 'Subscription failed. Please try again.'),
      );
    }
  }
}
