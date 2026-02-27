import 'package:flutter/foundation.dart';
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

  /// Step 1: Create checkout order + Stripe PaymentIntent
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

  /// Step 2: Confirm payment after Stripe completes
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

  /// Full purchase flow: checkout -> confirm (Stripe payment sheet handled externally)
  Future<CheckoutResult> purchaseEsim({
    required String packageCode,
    required String packageName,
    required double price,
    required String customerEmail,
    required String customerName,
  }) async {
    final checkout = await createCheckout(
      packageCode: packageCode,
      packageName: packageName,
      price: price,
      customerEmail: customerEmail,
      customerName: customerName,
    );

    if (!checkout.success) return checkout;

    // TODO: Present Stripe Payment Sheet with checkout.clientSecret
    // For now, auto-confirm (works in dev mode)
    if (checkout.orderId != null && checkout.paymentIntentId != null) {
      return confirmPayment(
        orderId: checkout.orderId!,
        paymentIntentId: checkout.paymentIntentId!,
      );
    }

    return checkout;
  }

  Future<CheckoutResult> createSubscription({
    required String plan,
    required String billingPeriod,
  }) async {
    return const CheckoutResult(
      success: false,
      error: 'Payment service temporarily unavailable',
    );
  }
}
