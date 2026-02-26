class EsimPlan {
  final String id;
  final String name;
  final String? description;
  final double dataGB;
  final int durationDays;
  final double priceUSD;
  final String? speed;
  final String location;
  final String locationCode;

  const EsimPlan({
    required this.id,
    required this.name,
    this.description,
    required this.dataGB,
    required this.durationDays,
    required this.priceUSD,
    this.speed,
    required this.location,
    required this.locationCode,
  });

  factory EsimPlan.fromJson(Map<String, dynamic> json) {
    double dataGB = (json['dataGB'] ?? 0).toDouble();
    if (dataGB == 0 && json['volume'] != null) {
      dataGB = (json['volume'] as num).toDouble() / 1024;
    }

    String locationName = json['location']?.toString() ?? '';
    final networkList = json['locationNetworkList'] as List<dynamic>?;
    if (networkList != null && networkList.isNotEmpty) {
      locationName = (networkList[0] as Map<String, dynamic>)['locationName']?.toString() ?? locationName;
    }

    return EsimPlan(
      id: json['id']?.toString() ?? json['packageCode']?.toString() ?? '',
      name: json['name']?.toString() ?? json['packageName']?.toString() ?? '',
      description: json['description']?.toString(),
      dataGB: dataGB,
      durationDays: json['durationDays'] ?? json['duration'] ?? 0,
      priceUSD: (json['priceUSD'] ?? json['price'] ?? 0).toDouble(),
      speed: json['speed']?.toString(),
      location: locationName,
      locationCode: json['locationCode']?.toString() ?? '',
    );
  }
}

class EsimOrder {
  final String? esimTranNo;
  final String orderNo;
  final String? iccid;
  final String? lpaCode;
  final String? qrCodeUrl;
  final String? status;
  final String? smdpStatus;
  final int? totalVolume;
  final String? expiredTime;
  final List<EsimPackageInfo> packages;

  const EsimOrder({
    this.esimTranNo,
    required this.orderNo,
    this.iccid,
    this.lpaCode,
    this.qrCodeUrl,
    this.status,
    this.smdpStatus,
    this.totalVolume,
    this.expiredTime,
    this.packages = const [],
  });

  factory EsimOrder.fromJson(Map<String, dynamic> json) => EsimOrder(
        esimTranNo: json['esimTranNo']?.toString(),
        orderNo: json['orderNo']?.toString() ?? '',
        iccid: json['iccid']?.toString(),
        lpaCode: json['ac']?.toString(),
        qrCodeUrl: json['qrCodeUrl']?.toString(),
        status: json['status']?.toString(),
        smdpStatus: json['smdpStatus']?.toString(),
        totalVolume: json['totalVolume'] as int?,
        expiredTime: json['expiredTime']?.toString(),
        packages: (json['packageList'] as List<dynamic>?)
                ?.map((e) => EsimPackageInfo.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  bool get isActive =>
      smdpStatus == 'RELEASED' || smdpStatus == 'IN_USE' || status == 'active';

  bool get isExpired {
    if (expiredTime == null) return false;
    final expiry = DateTime.tryParse(expiredTime!);
    return expiry != null && expiry.isBefore(DateTime.now());
  }

  String get packageName => packages.isNotEmpty ? packages.first.packageName : 'eSIM';
}

class EsimPackageInfo {
  final String packageName;
  final int? totalVolume;
  final String? expiredTime;

  const EsimPackageInfo({
    required this.packageName,
    this.totalVolume,
    this.expiredTime,
  });

  factory EsimPackageInfo.fromJson(Map<String, dynamic> json) => EsimPackageInfo(
        packageName: json['packageName']?.toString() ?? '',
        totalVolume: json['totalVolume'] as int?,
        expiredTime: json['expiredTime']?.toString(),
      );
}

class EsimUsage {
  final String iccid;
  final String? orderNo;
  final String? packageName;
  final String? status;
  final int totalVolume;
  final int orderUsage;
  final int remainingData;
  final double usagePercent;
  final String? expiredTime;

  const EsimUsage({
    required this.iccid,
    this.orderNo,
    this.packageName,
    this.status,
    required this.totalVolume,
    required this.orderUsage,
    required this.remainingData,
    required this.usagePercent,
    this.expiredTime,
  });

  factory EsimUsage.fromJson(Map<String, dynamic> json) => EsimUsage(
        iccid: json['iccid']?.toString() ?? '',
        orderNo: json['orderNo']?.toString(),
        packageName: json['packageName']?.toString(),
        status: json['status']?.toString(),
        totalVolume: json['totalVolume'] ?? 0,
        orderUsage: json['orderUsage'] ?? 0,
        remainingData: json['remainingData'] ?? 0,
        usagePercent: (json['usagePercent'] ?? 0).toDouble(),
        expiredTime: json['expiredTime']?.toString(),
      );
}

class TopUpPackage {
  final String packageCode;
  final String name;
  final int price;
  final int volume;
  final int duration;
  final String currencyCode;

  const TopUpPackage({
    required this.packageCode,
    required this.name,
    required this.price,
    required this.volume,
    required this.duration,
    required this.currencyCode,
  });

  factory TopUpPackage.fromJson(Map<String, dynamic> json) => TopUpPackage(
        packageCode: json['packageCode']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: json['price'] ?? 0,
        volume: json['volume'] ?? 0,
        duration: json['duration'] ?? 0,
        currencyCode: json['currencyCode']?.toString() ?? 'USD',
      );
}
