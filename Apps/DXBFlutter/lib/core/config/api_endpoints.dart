class ApiEndpoints {
  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authApple = '/auth/apple';
  static const String authSendOtp = '/auth/email/send-otp';
  static const String authVerifyOtp = '/auth/email/verify';
  static const String authRefresh = '/auth/refresh';
  static const String authResetPassword = '/auth/reset-password';

  // eSIM
  static const String esimPackages = '/esim/packages';
  static const String esimOrders = '/esim/orders';
  static const String esimPurchase = '/esim/purchase';
  static const String esimPurchaseApplePay = '/esim/purchase/apple-pay';
  static const String esimQuery = '/esim/query';
  static const String esimUsage = '/esim/usage';
  static const String esimTopup = '/esim/topup';
  static const String esimSuspend = '/esim/suspend';
  static const String esimCancel = '/esim/cancel';
  static const String esimBalance = '/esim/balance';
  static const String esimStock = '/esim/stock';

  // Subscriptions
  static const String subscriptionsMe = '/subscriptions/me';
  static const String subscriptionsCreate = '/subscriptions/create';
  static const String subscriptionsCreateApplePay = '/subscriptions/create-apple-pay';
  static const String subscriptionsChange = '/subscriptions/change';
  static const String subscriptionsCancel = '/subscriptions/cancel';

  // Offers
  static const String offers = '/offers';
  static const String offersCategories = '/offers/categories';
  static String offerDetail(String id) => '/offers/$id';
  static String offerClick(String id) => '/offers/$id/click';

  // Rewards
  static const String rewardsSummary = '/rewards/summary';
  static const String rewardsMissions = '/rewards/missions';
  static const String rewardsCheckin = '/rewards/checkin';

  // Raffles
  static const String rafflesActive = '/raffles/active';
  static const String rafflesEnter = '/raffles/enter';

  // Promo
  static const String promoValidate = '/promo/validate';

  // Checkout
  static const String checkout = '/checkout';
  static const String checkoutConfirm = '/checkout/confirm';

  // Health
  static const String health = '/health';
}
