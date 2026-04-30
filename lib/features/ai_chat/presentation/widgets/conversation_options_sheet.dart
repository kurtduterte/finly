import 'package:flutter/material.dart';

class ConversationOptionsSheet extends StatelessWidget {
  const ConversationOptionsSheet({
    required this.onRename,
    required this.onDelete,
    super.key,
  });

  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              onRename();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: cs.error),
            title: Text('Delete', style: TextStyle(color: cs.error)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
