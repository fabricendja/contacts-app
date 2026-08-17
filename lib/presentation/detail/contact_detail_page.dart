import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/nationalities.dart';
import '../../domain/entities/contact.dart';
import '../favorites/cubit/favorites_cubit.dart';
import '../shared/contact_labels.dart';

class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key, required this.contact});

  final Contact contact;

  /// Ne conserve que les caractères significatifs du numéro pour les URI
  /// tel:/sms: (les parenthèses et espaces de l'API sont superflus).
  String _cleanNumber(String number) =>
      number.replaceAll(RegExp(r'[^0-9+]'), '');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<FavoritesCubit, List<Contact>>(
            builder: (context, favorites) {
              final isFavorite = favorites.any((c) => c.id == contact.id);
              return IconButton(
                tooltip:
                    isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                onPressed: () =>
                    context.read<FavoritesCubit>().toggle(contact),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? theme.colorScheme.primary : null,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Hero(
              tag: 'avatar-${contact.id}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    width: 3,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: contact.pictureUrl.isEmpty
                      ? null
                      : CachedNetworkImageProvider(contact.pictureUrl),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            contact.displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              '${contact.age} ans',
              kNationalities[contact.nationality.toLowerCase()] ??
                  contact.nationality,
            ].join('  ·  '),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.call_rounded,
                label: 'Appeler',
                onPressed: () => _launch(
                  context,
                  Uri(scheme: 'tel', path: _cleanNumber(contact.cell)),
                ),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.sms_rounded,
                label: 'Message',
                onPressed: () => _launch(
                  context,
                  Uri(scheme: 'sms', path: _cleanNumber(contact.cell)),
                ),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.mail_rounded,
                label: 'Email',
                onPressed: () => _launch(
                  context,
                  Uri(scheme: 'mailto', path: contact.email),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _InfoSection(
            title: 'Profil',
            children: [
              _InfoTile(
                icon: contact.isFemale
                    ? Icons.female_rounded
                    : Icons.male_rounded,
                label: 'Genre',
                value: contact.genderLabel,
              ),
              _InfoTile(
                icon: Icons.cake_outlined,
                label: 'Âge',
                value: '${contact.age} ans',
              ),
              _InfoTile(
                icon: Icons.flag_outlined,
                label: 'Nationalité',
                value: kNationalities[contact.nationality.toLowerCase()] ??
                    contact.nationality,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Coordonnées',
            children: [
              _InfoTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: contact.email,
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Téléphone fixe',
                value: contact.phone,
              ),
              _InfoTile(
                icon: Icons.smartphone_rounded,
                label: 'Mobile',
                value: contact.cell,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Adresse',
            children: [
              _InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Domicile',
                value: contact.fullAddress,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    // On tente directement le lancement plutôt que canLaunchUrl, qui renvoie
    // de faux négatifs sur Android 11+ selon la visibilité des packages.
    final messenger = ScaffoldMessenger.of(context);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      launched = false;
    }
    if (!launched) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Aucune application disponible pour cette action.'),
          ),
        );
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 6),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 60),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('$label copié dans le presse-papiers')),
          );
      },
    );
  }
}
