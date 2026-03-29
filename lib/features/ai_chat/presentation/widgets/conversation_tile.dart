import 'package:finly/core/db/app_database.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conv,
    required this.onTap,
    required this.onLongPress,
    required this.onDismissed,
    super.key,
  });
  final Conversation conv;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final d = conv.createdAt.toLocal();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}'
        '-${d.day.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(conv.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        title: Text(conv.title),
        subtitle: Text(dateStr),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
