import 'package:finly/core/theme/theme_provider.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/model_setup/presentation/widgets/gemma_status_icon.dart';
import 'package:finly/features/settings/presentation/screens/change_password_screen.dart';
import 'package:finly/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    final displayName =
        (user?.displayName?.isNotEmpty == true ? user!.displayName : null) ??
        (user?.email.isNotEmpty == true ? user!.email : null) ??
        'User';
    final initial = displayName[0].toUpperCase();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          Text(
            'Profile',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _ProfileCard(
            initial: initial,
            displayName: displayName,
            email: user?.email ?? '',
            cs: cs,
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Appearance', cs: cs),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? cs.secondary : const Color(0xFFD97706),
            title: isDark ? 'Dark mode' : 'Light mode',
            cs: cs,
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
              activeThumbColor: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'Account', cs: cs),
          _SettingsTile(
            icon: Icons.edit_outlined,
            iconColor: cs.primary,
            title: 'Edit profile',
            cs: cs,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            iconColor: cs.secondary,
            title: 'Change password',
            cs: cs,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: cs.error,
            title: 'Sign out',
            titleColor: cs.error,
            cs: cs,
            onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'AI Model', cs: cs),
          _SettingsTile(
            icon: Icons.psychology_rounded,
            iconColor: cs.secondary,
            title: 'Gemma Status',
            cs: cs,
            trailing: const GemmaStatusIcon(),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Finly · Offline-first finance',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.initial,
    required this.displayName,
    required this.email,
    required this.cs,
  });

  final String initial;
  final String displayName;
  final String email;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.inversePrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.cs});

  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.cs,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final ColorScheme cs;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = titleColor ?? cs.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: effectiveTitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  )
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
