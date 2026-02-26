class PartnerOffer {
  final String id;
  final String title;
  final String description;
  final String category;
  final String partnerName;
  final String partnerSlug;
  final String? affiliateUrl;
  final String? imageUrl;
  final int discountPercent;
  final String? discountType;
  final bool isGlobal;
  final List<String> countryCodes;
  final String? city;
  final String? tierRequired;
  final bool isActive;

  const PartnerOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.partnerName,
    required this.partnerSlug,
    this.affiliateUrl,
    this.imageUrl,
    this.discountPercent = 0,
    this.discountType,
    this.isGlobal = false,
    this.countryCodes = const [],
    this.city,
    this.tierRequired,
    this.isActive = true,
  });

  factory PartnerOffer.fromJson(Map<String, dynamic> json) => PartnerOffer(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        partnerName: json['partner_name']?.toString() ?? json['partner_slug']?.toString() ?? '',
        partnerSlug: json['partner_slug']?.toString() ?? '',
        affiliateUrl: json['affiliate_url_template']?.toString() ?? json['affiliate_url']?.toString(),
        imageUrl: json['image_url']?.toString(),
        discountPercent: json['discount_percent'] ?? 0,
        discountType: json['discount_type']?.toString(),
        isGlobal: json['is_global'] ?? false,
        countryCodes: (json['country_codes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        city: json['city']?.toString(),
        tierRequired: json['tier_required']?.toString(),
        isActive: json['is_active'] ?? true,
      );
}

class OfferCategory {
  final String id;
  final String label;
  final String? icon;

  const OfferCategory({
    required this.id,
    required this.label,
    this.icon,
  });

  factory OfferCategory.fromJson(Map<String, dynamic> json) => OfferCategory(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        icon: json['icon']?.toString(),
      );
}
