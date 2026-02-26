import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../offers/models/offer_models.dart';

class OffersSection extends StatelessWidget {
  final List<PartnerOffer> offers;
  final VoidCallback? onViewAll;
  final ValueChanged<PartnerOffer>? onOfferTap;

  const OffersSection({
    super.key,
    required this.offers,
    this.onViewAll,
    this.onOfferTap,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const Text(
                'Exclusive Offers',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: offers.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              return _OfferCard(
                offer: offers[index],
                onTap: () => onOfferTap?.call(offers[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  final PartnerOffer offer;
  final VoidCallback? onTap;

  const _OfferCard({required this.offer, this.onTap});

  String get _locationTag {
    if (offer.countryCodes.isNotEmpty) {
      final code = offer.countryCodes.first;
      final flag = _flagEmoji(code);
      return offer.city != null ? '$flag ${offer.city}' : flag;
    }
    if (offer.isGlobal) return '\u{1F30D} Global';
    return '';
  }

  String _flagEmoji(String countryCode) {
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '\u{1F30D}';
    final first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCodes([first, second]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  offer.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: offer.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _shimmerPlaceholder(),
                          errorWidget: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                  ),
                  if (_locationTag.isNotEmpty)
                    Positioned(
                      bottom: 6, left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          color: Colors.black.withValues(alpha: 0.5),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(_locationTag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  if (offer.discountPercent > 0)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('-${offer.discountPercent}%',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          offer.partnerName,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_outward_rounded, size: 10, color: AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.accent.withValues(alpha: 0.12), AppColors.surface],
        ),
      ),
      child: Icon(Icons.local_offer_rounded, size: 28, color: Colors.white.withValues(alpha: 0.3)),
    );
  }
}
