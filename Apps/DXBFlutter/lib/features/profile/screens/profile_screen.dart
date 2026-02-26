import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../subscription/screens/subscription_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.base),
          _ProfileHeader(
            name: auth.user?.name ?? 'User',
            email: auth.user?.email ?? '',
            tier: dashboard.subscription?.plan,
          ),
          const SizedBox(height: AppSpacing.lg),
          _MembershipCard(
            hasSub: dashboard.subscription != null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
          ),
          const SizedBox(height: AppSpacing.base),
          _SettingsSection(
            title: 'ACCOUNT',
            items: const [
              _SettingsItemData(icon: Icons.person_rounded, title: 'Personal Information'),
              _SettingsItemData(icon: Icons.notifications_rounded, title: 'Notifications'),
              _SettingsItemData(icon: Icons.lock_rounded, title: 'Security'),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _SettingsSection(
            title: 'SUPPORT',
            items: [
              _SettingsItemData(icon: Icons.help_rounded, title: 'Help Center', onTap: () => _showSupport(context)),
              _SettingsItemData(icon: Icons.email_rounded, title: 'Contact Us', onTap: () => _openUrl('mailto:support@simpass.io')),
              _SettingsItemData(icon: Icons.description_rounded, title: 'Terms of Service', color: AppColors.textSecondary, onTap: () => _openUrl('https://simpass.io/terms')),
              _SettingsItemData(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy', color: AppColors.textSecondary, onTap: () => _openUrl('https://simpass.io/privacy')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SignOutButton(onTap: () => _confirmSignOut(context)),
          const SizedBox(height: AppSpacing.lg),
          _AppInfo(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (_) => const _SupportSheet(),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? tier;
  const _ProfileHeader({required this.name, required this.email, this.tier});

  String get _initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.isNotEmpty) return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
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
          color: AppColors.accent.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD0FF50), AppColors.accent],
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (tier != null) ...[
            const SizedBox(height: 12),
            _TierBadge(tier: tier!),
          ],
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  Color get _color {
    switch (tier.toLowerCase()) {
      case 'elite': return AppColors.accent;
      case 'black': return Colors.white;
      default: return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(tier.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: _color)),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final bool hasSub;
  final VoidCallback onTap;
  const _MembershipCard({required this.hasSub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.sm), color: AppColors.accent.withValues(alpha: 0.12)),
              child: const Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hasSub ? 'My Subscription' : 'Become a Member',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(hasSub ? 'Manage your plan' : 'Up to -30% on eSIMs',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 12, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SettingsItemData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _SettingsItemData({required this.icon, required this.title, this.color = AppColors.accent, this.onTap});
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItemData> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.textTertiary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
          ),
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(height: 0.5, indent: 56, color: AppColors.surfaceBorder);
              }
              final item = items[index ~/ 2];
              return _settingsRow(item);
            }),
          ),
        ),
      ],
    );
  }

  Widget _settingsRow(_SettingsItemData item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.sm), color: item.color.withValues(alpha: 0.08)),
              child: Icon(item.icon, size: 14, color: item.color),
            ),
            const SizedBox(width: 12),
            Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, size: 10, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'DANGER ZONE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                SizedBox(width: 8),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('SimPass v1.0.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary)),
        SizedBox(height: 6),
        Text('Made with ❤️ in Dubai', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _SupportSheet extends StatelessWidget {
  const _SupportSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          controller: controller,
          children: [
            Row(
              children: [
                const Text('SUPPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.textSecondary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, size: 24, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.1)),
              child: const Icon(Icons.headset_mic_rounded, size: 30, color: AppColors.accent),
            ),
            const SizedBox(height: 14),
            const Text('How can we help?', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text("We're here for you 24/7", textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xxl),
            const Text('FAQ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.textTertiary)),
            const SizedBox(height: 12),
            _faqItem('How to install my eSIM?', 'Open Settings > Cellular > Add eSIM'),
            _faqItem('Can I use multiple eSIMs?', 'Yes, your phone supports dual SIM'),
            _faqItem('How to get a refund?', 'Contact our support team within 24h'),
            const SizedBox(height: AppSpacing.lg),
            _contactTile(Icons.email_rounded, 'Email', 'support@simpass.io', AppColors.info, () {
              launchUrl(Uri.parse('mailto:support@simpass.io'));
            }),
            const SizedBox(height: 10),
            _contactTile(Icons.chat_rounded, 'Live Chat', 'Available 24/7', AppColors.accent, () {
              launchUrl(Uri.parse('https://simpass.io/chat'));
            }),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(a, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _contactTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.sm), color: color.withValues(alpha: 0.12)),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, size: 11, color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}
