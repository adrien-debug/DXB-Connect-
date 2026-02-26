import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/esim_models.dart';
import '../providers/esim_provider.dart';
import '../widgets/usage_arc.dart';
import '../widgets/esim_status_badge.dart';
import '../widgets/country_helper.dart';

class EsimDetailScreen extends ConsumerStatefulWidget {
  final EsimOrder esim;

  const EsimDetailScreen({super.key, required this.esim});

  @override
  ConsumerState<EsimDetailScreen> createState() => _EsimDetailScreenState();
}

class _EsimDetailScreenState extends ConsumerState<EsimDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(esimDetailProvider.notifier).loadDetail(
            widget.esim.iccid ?? '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(esimDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'eSIM DETAILS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref
                .read(esimDetailProvider.notifier)
                .loadDetail(widget.esim.iccid ?? ''),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _UsageHero(esim: widget.esim, detail: detail),
                  const SizedBox(height: AppSpacing.base),
                  _InfoCard(
                    esim: widget.esim,
                    onShowQR: () => _showQRSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _ActionsGrid(
                    esim: widget.esim,
                    onRefresh: () => ref
                        .read(esimDetailProvider.notifier)
                        .loadDetail(widget.esim.iccid ?? ''),
                    onShowQR: () => _showQRSheet(context),
                    onSuspend: () => _suspendEsim(),
                  ),
                  if (detail.topUpPackages.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.base),
                    _TopUpSection(
                      packages: detail.topUpPackages,
                      onBuy: (pkg) => _buyTopUp(pkg),
                    ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          if (detail.isActionInProgress)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoadingIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        detail.actionMessage ?? 'Processing...',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showQRSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _QRCodeSheet(esim: widget.esim),
    );
  }

  Future<void> _suspendEsim() async {
    final notifier = ref.read(esimDetailProvider.notifier);
    final success = await notifier.suspendEsim(widget.esim.orderNo);
    if (success && mounted) {
      ref.read(esimListProvider.notifier).loadEsims();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('eSIM suspended')),
      );
    }
  }

  Future<void> _buyTopUp(TopUpPackage pkg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Top Up'),
        content: Text('Add ${formatVolume(pkg.volume)} for ${pkg.duration} days?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Buy for \$${(pkg.price / 100).toStringAsFixed(2)}'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(esimDetailProvider.notifier);
      final success = await notifier.topUpEsim(
        widget.esim.iccid ?? '',
        pkg.packageCode,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Top-up successful!')),
        );
        notifier.loadDetail(widget.esim.iccid ?? '');
      }
    }
  }
}

class _UsageHero extends StatelessWidget {
  final EsimOrder esim;
  final EsimDetailData detail;

  const _UsageHero({required this.esim, required this.detail});

  @override
  Widget build(BuildContext context) {
    final status = esim.smdpStatus ?? esim.status ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F14),
            Color(0xFF141414),
            Color(0xFF111115),
          ],
        ),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          UsageArc(
            progress: detail.usage?.usagePercent != null
                ? detail.usage!.usagePercent / 100
                : 0,
            child: detail.isLoadingUsage
                ? const LoadingIndicator(size: 24)
                : detail.usage != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatVolume(detail.usage!.orderUsage),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'of ${formatVolume(detail.usage!.totalVolume)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sim_card_rounded,
                              size: 26, color: AppColors.textTertiary),
                          Text('Unavailable',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary)),
                        ],
                      ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            esim.packageName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          EsimStatusBadge(status: status),
          if (detail.usage != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _UsageStat(
                  label: 'Used',
                  value: formatVolume(detail.usage!.orderUsage),
                  color: AppColors.warning,
                ),
                Container(
                  width: 0.5,
                  height: 32,
                  color: AppColors.surfaceBorder,
                ),
                _UsageStat(
                  label: 'Remaining',
                  value: formatVolume(detail.usage!.remainingData),
                  color: AppColors.success,
                ),
                Container(
                  width: 0.5,
                  height: 32,
                  color: AppColors.surfaceBorder,
                ),
                _UsageStat(
                  label: 'Expires',
                  value: _formatExpiry(detail.usage!.expiredTime),
                  color: AppColors.info,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatExpiry(String? raw) {
    if (raw == null) return '--';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    return '${diff.inHours}h left';
  }
}

class _UsageStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _UsageStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final EsimOrder esim;
  final VoidCallback onShowQR;

  const _InfoCard({required this.esim, required this.onShowQR});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onShowQR,
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_rounded, size: 16, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'QR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('ICCID', esim.iccid ?? 'Pending'),
          _infoRow('Order', esim.orderNo),
          _infoRow('Volume', formatVolume(esim.totalVolume)),
          _infoRow('Expires', _formatExpiry(esim.expiredTime)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiry(String? raw) {
    if (raw == null || raw.isEmpty) return '--';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActionsGrid extends StatelessWidget {
  final EsimOrder esim;
  final VoidCallback onRefresh;
  final VoidCallback onShowQR;
  final VoidCallback onSuspend;

  const _ActionsGrid({
    required this.esim,
    required this.onRefresh,
    required this.onShowQR,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = EsimStatusBadge.isActiveStatus(
        esim.smdpStatus ?? esim.status ?? '');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                color: AppColors.info,
                onTap: onRefresh,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (isActive)
              Expanded(
                child: _ActionTile(
                  icon: Icons.pause_circle_filled_rounded,
                  label: 'Suspend',
                  color: AppColors.warning,
                  onTap: onSuspend,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onShowQR,
            icon: const Icon(Icons.qr_code_rounded),
            label: const Text('View Installation QR Code'),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopUpSection extends StatelessWidget {
  final List<TopUpPackage> packages;
  final ValueChanged<TopUpPackage> onBuy;

  const _TopUpSection({required this.packages, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Up',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...packages.take(3).map((pkg) => _TopUpRow(pkg: pkg, onBuy: () => onBuy(pkg))),
        ],
      ),
    );
  }
}

class _TopUpRow extends StatelessWidget {
  final TopUpPackage pkg;
  final VoidCallback onBuy;

  const _TopUpRow({required this.pkg, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.download_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      formatVolume(pkg.volume),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${pkg.duration}d',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(pkg.price / 100).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onBuy,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Buy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QRCodeSheet extends StatelessWidget {
  final EsimOrder esim;

  const _QRCodeSheet({required this.esim});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Installation QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (esim.lpaCode != null && esim.lpaCode!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: QrImageView(
                  data: esim.lpaCode!,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              )
            else
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_rounded, size: 50, color: AppColors.textTertiary),
                    SizedBox(height: 10),
                    Text('QR Code unavailable',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Scan this QR code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Settings > Cellular > Add eSIM Plan',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (esim.lpaCode != null && esim.lpaCode!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Manual code',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: esim.lpaCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('LPA code copied!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          esim.lpaCode!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy_rounded, size: 14, color: AppColors.accent),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
