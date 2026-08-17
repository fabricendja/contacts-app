import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contact.dart';
import '../../shared/contact_labels.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.isFavorite = false,
  });

  final Contact contact;
  final VoidCallback onTap;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Hero(
        tag: 'avatar-${contact.id}',
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: contact.thumbnailUrl.isEmpty
                ? null
                : CachedNetworkImageProvider(contact.thumbnailUrl),
            child: contact.thumbnailUrl.isEmpty
                ? Text(contact.firstName.isEmpty ? '?' : contact.firstName[0])
                : null,
          ),
        ),
      ),
      title: Text(
        contact.displayName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${contact.city}, ${contact.country}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isFavorite
          ? Icon(
              Icons.favorite_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.outline,
            ),
    );
  }
}
