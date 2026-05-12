import 'package:finly/features/settings/presentation/widgets/profile_field.dart';
import 'package:flutter/material.dart';

class EditProfileFormInputs extends StatelessWidget {
  const EditProfileFormInputs({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileField(
          controller: nameController,
          label: 'Display name',
          icon: Icons.person_outline_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        ProfileField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 12),
        ProfileField(
          controller: phoneController,
          label: 'Phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        ProfileField(
          controller: addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
        ),
      ],
    );
  }
}
