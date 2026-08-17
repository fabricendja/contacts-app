import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/utils/debouncer.dart';
import '../../domain/entities/contact.dart';
import '../detail/contact_detail_page.dart';
import '../favorites/cubit/favorites_cubit.dart';
import 'cubit/contacts_cubit.dart';
import 'widgets/contact_tile.dart';
import 'widgets/contacts_shimmer.dart';
import 'widgets/error_view.dart';
import 'widgets/filter_bar.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_showFavoritesOnly) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<ContactsCubit>().loadMore();
    }
  }

  void _openDetail(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactDetailPage(contact: contact)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            tooltip: theme.brightness == Brightness.dark
                ? 'Passer en mode clair'
                : 'Passer en mode sombre',
            onPressed: () =>
                ThemeScope.of(context).toggle(theme.brightness),
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) => _debouncer.run(
                () => context.read<ContactsCubit>().search(value),
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un nom, un email, une ville…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _searchController,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ContactsCubit>().search('');
                          },
                        ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          FilterBar(
            showFavoritesOnly: _showFavoritesOnly,
            onFavoritesToggled: (value) =>
                setState(() => _showFavoritesOnly = value),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _showFavoritesOnly ? _buildFavorites() : _buildContacts(),
          ),
        ],
      ),
    );
  }

  Widget _buildContacts() {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        switch (state.status) {
          case ContactsStatus.initial:
          case ContactsStatus.loading:
            return const ContactsShimmer();
          case ContactsStatus.failure:
            return ErrorView(
              message: state.errorMessage ?? 'Une erreur est survenue.',
              onRetry: () => context.read<ContactsCubit>().loadInitial(),
            );
          case ContactsStatus.success:
            final contacts = state.visibleContacts;
            if (contacts.isEmpty) {
              return _EmptyView(
                message: state.query.isEmpty
                    ? 'Aucun contact trouvé.'
                    : 'Aucun résultat pour « ${state.query} ».',
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ContactsCubit>().refresh(),
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: contacts.length + 1,
                separatorBuilder: (_, _) => const Divider(indent: 88),
                itemBuilder: (context, index) {
                  if (index == contacts.length) {
                    return _ListFooter(state: state);
                  }
                  final contact = contacts[index];
                  return BlocBuilder<FavoritesCubit, List<Contact>>(
                    builder: (context, favorites) => ContactTile(
                      contact: contact,
                      isFavorite: favorites.any((c) => c.id == contact.id),
                      onTap: () => _openDetail(contact),
                    ),
                  );
                },
              ),
            );
        }
      },
    );
  }

  Widget _buildFavorites() {
    return BlocBuilder<FavoritesCubit, List<Contact>>(
      builder: (context, favorites) {
        final query =
            context.select((ContactsCubit c) => c.state.query).toLowerCase();
        final visible = query.isEmpty
            ? favorites
            : favorites
                .where((c) => c.fullName.toLowerCase().contains(query))
                .toList();
        if (visible.isEmpty) {
          return const _EmptyView(
            message:
                'Aucun favori pour le moment.\nAjoutez-en depuis la fiche d’un contact.',
          );
        }
        return ListView.separated(
          itemCount: visible.length,
          separatorBuilder: (_, _) => const Divider(indent: 88),
          itemBuilder: (context, index) => ContactTile(
            contact: visible[index],
            isFavorite: true,
            onTap: () => _openDetail(visible[index]),
          ),
        );
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final ContactsState state;

  @override
  Widget build(BuildContext context) {
    // Pas de pagination pendant qu'une recherche filtre la liste.
    if (state.query.isNotEmpty) return const SizedBox.shrink();

    if (state.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: () => context.read<ContactsCubit>().loadMore(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Le chargement a échoué — réessayer'),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
