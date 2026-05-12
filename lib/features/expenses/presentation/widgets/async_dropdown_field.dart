import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncDropdownField<T> extends StatelessWidget {
  const AsyncDropdownField({
    required this.asyncItems,
    required this.selectedValue,
    required this.label,
    required this.errorText,
    required this.itemLabel,
    required this.onChanged,
    super.key,
  });

  final AsyncValue<List<T>> asyncItems;
  final T? selectedValue;
  final String label;
  final String errorText;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return asyncItems.when(
      data: (items) => DropdownButtonFormField<T>(
        initialValue: selectedValue,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      ),
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Text(errorText),
    );
  }
}
