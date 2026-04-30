import 'package:finly/core/theme/theme_provider.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/model_setup/presentation/widgets/gemma_status_icon.dart';
import 'package:finly/features/settings/presentation/screens/change_password_screen.dart';
import 'package:finly/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:finly/features/settings/presentation/widgets/profile_card.dart';
import 'package:finly/features/settings/presentation/widgets/section_label.dart';
import 'package:finly/features/settings/presentation/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
          ProfileCard(
            initial: initial,
            displayName: displayName,
            email: user?.email ?? '',
          ),
          const SizedBox(height: 24),
          const SectionLabel(label: 'Appearance'),
          SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? cs.secondary : const Color(0xFFD97706),
            title: isDark ? 'Dark mode' : 'Light mode',
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
              activeThumbColor: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          const SectionLabel(label: 'Account'),
          SettingsTile(
            icon: Icons.edit_outlined,
            iconColor: cs.primary,
            title: 'Edit profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.lock_outline_rounded,
            iconColor: cs.secondary,
            title: 'Change password',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: cs.error,
            title: 'Sign out',
            titleColor: cs.error,
            onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
          const SizedBox(height: 16),
          const SectionLabel(label: 'AI Model'),
          SettingsTile(
            icon: Icons.psychology_rounded,
            iconColor: cs.secondary,
            title: 'Gemma Status',
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
