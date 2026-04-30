import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/settings/presentation/providers/settings_providers.dart';
import 'package:finly/features/settings/presentation/widgets/profile_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();

    ref.listenManual(profileExtrasProvider, (_, next) {
      next.whenData((extras) {
        if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = extras.phone;
        if (_addressCtrl.text.isEmpty) _addressCtrl.text = extras.address;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .updateDisplayName(_nameCtrl.text.trim());

      await ref.read(profileExtrasProvider.notifier).save(
            phone: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileField(
              controller: _nameCtrl,
              label: 'Display name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            ProfileField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 12),
            ProfileField(
              controller: _phoneCtrl,
              label: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            ProfileField(
              controller: _addressCtrl,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save changes'),
            ),
            const SizedBox(height: 12),
            Text(
              'Display name is synced with your account.\n'
              'Phone and address are stored locally on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
