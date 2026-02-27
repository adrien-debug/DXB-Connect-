import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../api/api_client.dart';
import '../config/api_endpoints.dart';

class CheckoutResult {
  final bool success;
  final String? orderId;
  final String? orderNumber;
  final String? clientSecret;
  final String? paymentIntentId;
  final String? error;

  const CheckoutResult({
    required this.success,
    this.orderId,
    this.orderNumber,
    this.clientSecret,
    this.paymentIntentId,
    this.error,
  });
}

class CheckoutService {
  final ApiClient _apiClient;

  CheckoutService(this._apiClient);

  /// Step 1: Create checkout order + Stripe PaymentIntent on backend
  Future<CheckoutResult> createCheckout({
    required String packageCode,
    required String packageName,
    required double price,
    required String customerEmail,
    required String customerName,
  }) async {
    try {
      final response = await _apiClient.post(
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

      final data = response.data;
      if (data['success'] == true) {
        return CheckoutResult(
          success: true,
          orderId: data['order']?['id']?.toString(),
          orderNumber: data['order']?['order_number']?.toString(),
          clientSecret: data['payment']?['client_secret']?.toString(),
          paymentIntentId: data['payment']?['payment_intent_id']?.toString(),
        );
      }
      return CheckoutResult(
        success: false,
        error: data['error']?.toString() ?? 'Checkout failed',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Checkout] createCheckout error: $e');
      return CheckoutResult(
        success: false,
        error: ApiClient.extractErrorMessage(e, 'Checkout failed. Please try again.'),
      );
    }
  }

  /// Step 2: Present Stripe Payment Sheet to user
  Future<bool> _presentPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'DXB Connect',
        style: ThemeMode.dark,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFFBAFF39),
            background: Color(0xFF1A1A1A),
            componentBackground: Color(0xFF2A2A2A),
            componentText: Color(0xFFFFFFFF),
            secondaryText: Color(0xFF9C9C9B),
            placeholderText: Color(0xFF656463),
            icon: Color(0xFFD0D0CF),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 16,
          ),
        ),
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    return true;
  }

  /// Step 3: Confirm payment with backend after Stripe completes
  Future<CheckoutResult> confirmPayment({
    required String orderId,
    required String paymentIntentId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.checkoutConfirm,
        data: {
          'order_id': orderId,
          'payment_intent_id': paymentIntentId,
        },
      );

      final data = response.data;
      return CheckoutResult(
        success: data['success'] == true,
        orderId: orderId,
        error: data['error']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Checkout] confirmPayment error: $e');
      return CheckoutResult(
        success: false,
        error: ApiClient.extractErrorMessage(e, 'Payment confirmation failed.'),
      );
    }
  }

  /// Full purchase flow: create order → present Payment Sheet → confirm
  Future<CheckoutResult> purchaseEsim({
    required String packageCode,
    required String packageName,
    required double price,
    required String customerEmail,
    required String customerName,
  }) async {
    // 1. Create order + PaymentIntent on backend
    final checkout = await createCheckout(
      packageCode: packageCode,
      packageName: packageName,
      price: price,
      customerEmail: customerEmail,
      customerName: customerName,
    );

    if (!checkout.success || checkout.clientSecret == null) {
      return CheckoutResult(
        success: false,
        error: checkout.error ?? 'Failed to create payment',
      );
    }

    // 2. Present Stripe Payment Sheet
    try {
      await _presentPaymentSheet(checkout.clientSecret!);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const CheckoutResult(success: false, error: 'Payment cancelled');
      }
      if (kDebugMode) debugPrint('[Checkout] Stripe error: ${e.error.localizedMessage}');
      return CheckoutResult(
        success: false,
        error: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Checkout] Payment Sheet error: $e');
      return CheckoutResult(
        success: false,
        error: 'Payment failed. Please try again.',
      );
    }

    // 3. Payment succeeded — confirm with backend
    if (checkout.orderId != null && checkout.paymentIntentId != null) {
      return confirmPayment(
        orderId: checkout.orderId!,
        paymentIntentId: checkout.paymentIntentId!,
      );
    }

    return checkout;
  }

  /// Create subscription via backend API
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
          error: data['error']?.toString() ?? 'Subscription failed',
        );
      }

      final clientSecret = data['clientSecret']?.toString();

      // If clientSecret returned → need Stripe confirmation (production)
      if (clientSecret != null && clientSecret.isNotEmpty) {
        try {
          await _presentPaymentSheet(clientSecret);
        } on StripeException catch (e) {
          if (e.error.code == FailureCode.Canceled) {
            return const CheckoutResult(success: false, error: 'Payment cancelled');
          }
          return CheckoutResult(
            success: false,
            error: e.error.localizedMessage ?? 'Payment failed',
          );
        }
      }

      return CheckoutResult(
        success: true,
        orderId: data['data']?['id']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Checkout] createSubscription error: $e');
      return CheckoutResult(
        success: false,
        error: ApiClient.extractErrorMessage(e, 'Subscription failed. Please try again.'),
      );
    }
  }
}
