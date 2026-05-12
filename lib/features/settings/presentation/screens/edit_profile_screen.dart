import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/settings/presentation/providers/settings_providers.dart';
import 'package:finly/features/settings/presentation/widgets/edit_profile_form_inputs.dart';
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

  void _setSaving(bool value) {
    if (!mounted) return;
    setState(() => _saving = value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveDisplayName() {
    return ref
        .read(authNotifierProvider.notifier)
        .updateDisplayName(_nameCtrl.text.trim());
  }

  Future<void> _saveProfileExtras() {
    return ref
        .read(profileExtrasProvider.notifier)
        .save(
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
  }

  Widget _buildSaveAction() {
    return TextButton(
      onPressed: _saving ? null : _save,
      child: _saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save'),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _setSaving(true);

    try {
      await _saveDisplayName();
      await _saveProfileExtras();

      if (mounted) {
        _showMessage('Profile updated');
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      if (mounted) _showMessage(e.toString());
    } finally {
      _setSaving(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [_buildSaveAction()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            EditProfileFormInputs(
              nameController: _nameCtrl,
              emailController: _emailCtrl,
              phoneController: _phoneCtrl,
              addressController: _addressCtrl,
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
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
