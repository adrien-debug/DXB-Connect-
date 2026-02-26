import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../esim/widgets/country_helper.dart';
import '../models/offer_models.dart';
import '../providers/offers_provider.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(offersProvider.notifier).loadOffers());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(offersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exclusive Offers'),
      ),
      body: Column(
        children: [
          if (data.categories.isNotEmpty)
            _CategoryFilter(
              categories: data.categories,
              selected: data.selectedCategory,
              onChanged: (cat) => ref.read(offersProvider.notifier).setCategory(cat),
            ),
          Expanded(
            child: data.isLoading && data.offers.isEmpty
                ? const Center(child: LoadingIndicator())
                : data.error != null && data.offers.isEmpty
                    ? _ErrorState(message: data.error!, onRetry: () => ref.read(offersProvider.notifier).loadOffers())
                    : data.filteredOffers.isEmpty
                        ? _emptyState(context)
                        : RefreshIndicator(
                            color: AppColors.accent,
                            backgroundColor: AppColors.surface,
                            onRefresh: () => ref.read(offersProvider.notifier).loadOffers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                              itemCount: data.filteredOffers.length,
                              itemBuilder: (_, i) => _OfferCard(
                                offer: data.filteredOffers[i],
                                onTap: () => _openOffer(data.filteredOffers[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _openOffer(PartnerOffer offer) async {
    final url = await ref.read(offersProvider.notifier).trackClick(offer.id);
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _CategoryFilter({required this.categories, this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        children: [
          _pill('All', selected == null, () => onChanged(null)),
          ...categories.map((cat) => _pill(cat[0].toUpperCase() + cat.substring(1), selected == cat, () => onChanged(cat))),
        ],
      ),
    );
  }

  Widget _pill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.surfaceBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final PartnerOffer offer;
  final VoidCallback onTap;
  const _OfferCard({required this.offer, required this.onTap});

  static const _categoryIcons = <String, String>{
    'restaurant': '🍽️', 'food': '🍽️',
    'hotel': '🏨', 'accommodation': '🏨',
    'activity': '🎯', 'experience': '🎯',
    'transport': '🚗', 'car': '🚗',
    'shopping': '🛍️',
    'lounge': '✈️',
    'insurance': '🛡️',
    'telecom': '📱',
  };

  String _categoryIcon(String c) => _categoryIcons[c.toLowerCase()] ?? '🌍';

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          (offer.partnerName.isNotEmpty ? offer.partnerName : 'Partner').toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (offer.category.isNotEmpty)
                        Text(
                          '${_categoryIcon(offer.category)} ${offer.category[0].toUpperCase()}${offer.category.substring(1)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
                        ),
                      const Spacer(),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.arrow_outward_rounded, size: 13, color: AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    offer.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          offer.imageUrl != null && offer.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: offer.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: AppColors.surfaceLight,
                    child: Container(color: AppColors.surface),
                  ),
                  errorWidget: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10, left: 10, right: 10,
            child: Row(
              children: [
                if (offer.countryCodes.isNotEmpty)
                  _badge(flagEmoji(offer.countryCodes.first) + (offer.city != null ? ' ${offer.city}' : ''))
                else if (offer.isGlobal)
                  _badge('🌍 Worldwide'),
                if (offer.tierRequired != null) ...[
                  const SizedBox(width: 6),
                  _tierBadge(offer.tierRequired!),
                ],
                const Spacer(),
                if (offer.discountPercent > 0) _discountBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.surface,
            AppColors.surfaceLight,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_categoryIcon(offer.category), style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              offer.partnerName.isNotEmpty ? offer.partnerName : 'Partner',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '-${offer.discountPercent}%',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  Widget _tierBadge(String tier) {
    final color = tier.toLowerCase() == 'elite' ? AppColors.accent
        : tier.toLowerCase() == 'black' ? Colors.white
        : const Color(0xFF888888);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 10, color: color),
          const SizedBox(width: 3),
          Text(tier.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: color)),
        ],
      ),
    );
  }
}

Widget _emptyState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_offers.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.local_offer_rounded,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'No offers yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back soon for exclusive deals\nand partner discounts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/dashboard/plans'),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(
                'Browse Plans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
