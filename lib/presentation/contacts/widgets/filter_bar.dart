import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/nationalities.dart';
import '../cubit/contacts_cubit.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.showFavoritesOnly,
    required this.onFavoritesToggled,
  });

  final bool showFavoritesOnly;
  final ValueChanged<bool> onFavoritesToggled;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ContactsCubit>().state;
    final gender = state.filters.gender;
    final nationality = state.filters.nationality;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Favoris'),
            avatar: showFavoritesOnly
                ? null
                : const Icon(Icons.favorite_border_rounded, size: 16),
            selected: showFavoritesOnly,
            showCheckmark: true,
            onSelected: onFavoritesToggled,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Femmes'),
            selected: gender == 'female',
            onSelected: (selected) => context
                .read<ContactsCubit>()
                .setGender(selected ? 'female' : null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Hommes'),
            selected: gender == 'male',
            onSelected: (selected) => context
                .read<ContactsCubit>()
                .setGender(selected ? 'male' : null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              nationality == null
                  ? 'Nationalité'
                  : kNationalities[nationality] ?? nationality.toUpperCase(),
            ),
            avatar: nationality == null
                ? const Icon(Icons.public_rounded, size: 16)
                : null,
            selected: nationality != null,
            showCheckmark: false,
            onSelected: (_) => _pickNationality(context, nationality),
          ),
          if (state.hasActiveFilters) ...[
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Effacer'),
              avatar: const Icon(Icons.close_rounded, size: 16),
              onPressed: () => context.read<ContactsCubit>().clearFilters(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickNationality(BuildContext context, String? current) async {
    final cubit = context.read<ContactsCubit>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Filtrer par nationalité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          for (final entry in kNationalities.entries)
            ListTile(
              title: Text(entry.value),
              trailing: current == entry.key
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.pop(context, entry.key),
            ),
        ],
      ),
    );
    if (selected != null) {
      // Re-sélectionner la nationalité active la désactive.
      await cubit.setNationality(selected == current ? null : selected);
    }
  }
}
