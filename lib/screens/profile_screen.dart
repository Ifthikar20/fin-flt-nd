import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user?.initials ?? '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Guest',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),

            // Menu items
            _ProfileSection(
              children: [
                _ProfileItem(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'My Storyboards',
                  onTap: () => context.push('/storyboard'),
                ),
                _ProfileItem(
                  icon: Icons.tune,
                  label: 'Preferences',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            _ProfileSection(
              children: [
                _ProfileItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notification Settings',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.shield_outlined,
                  label: 'Privacy',
                  onTap: () {},
                ),
                _ProfileItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            _ProfileSection(
              children: [
                _ProfileItem(
                  icon: Icons.info_outline,
                  label: 'About Fynda',
                  onTap: () {},
                  trailing: Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final List<Widget> children;

  const _ProfileSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 20, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
