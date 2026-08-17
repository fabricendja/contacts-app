part of 'contacts_cubit.dart';

enum ContactsStatus { initial, loading, success, failure }

class ContactsState extends Equatable {
  const ContactsState({
    this.status = ContactsStatus.initial,
    this.contacts = const [],
    this.page = 0,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.query = '',
    this.filters = const ContactFilters(),
    this.errorMessage,
  });

  final ContactsStatus status;
  final List<Contact> contacts;
  final int page;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final String query;
  final ContactFilters filters;
  final String? errorMessage;

  /// La recherche s'applique localement aux contacts déjà chargés :
  /// l'API ne propose pas de recherche texte.
  List<Contact> get visibleContacts {
    if (query.isEmpty) return contacts;
    final q = query.toLowerCase();
    return contacts
        .where((c) =>
            c.fullName.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.city.toLowerCase().contains(q))
        .toList();
  }

  bool get hasActiveFilters => !filters.isEmpty;

  ContactsState copyWith({
    ContactsStatus? status,
    List<Contact>? contacts,
    int? page,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    String? query,
    ContactFilters? filters,
    String? errorMessage,
  }) {
    return ContactsState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contacts,
        page,
        isLoadingMore,
        loadMoreFailed,
        query,
        filters.gender,
        filters.nationality,
        errorMessage,
      ];
}
