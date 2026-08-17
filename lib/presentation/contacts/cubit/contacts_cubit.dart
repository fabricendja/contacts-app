import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/contact.dart';
import '../../../domain/repositories/contact_repository.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(this._repository) : super(const ContactsState());

  final ContactRepository _repository;

  /// L'énoncé demande 50 contacts au premier chargement, puis infinite scroll.
  static const int initialPageSize = 50;
  static const int pageSize = 25;

  bool _isFetching = false;

  Future<void> loadInitial() async {
    emit(state.copyWith(status: ContactsStatus.loading, errorMessage: null));
    try {
      final contacts = await _repository.fetchContacts(
        page: 1,
        pageSize: initialPageSize,
        filters: state.filters,
      );
      emit(state.copyWith(
        status: ContactsStatus.success,
        contacts: contacts,
        // Le premier chargement de 50 compte comme 2 pages de 25.
        page: initialPageSize ~/ pageSize,
        loadMoreFailed: false,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ContactsStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || state.status != ContactsStatus.success) return;
    _isFetching = true;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final nextPage = state.page + 1;
      final newContacts = await _repository.fetchContacts(
        page: nextPage,
        pageSize: pageSize,
        filters: state.filters,
      );
      // Protège contre les rares doublons que l'API peut encore renvoyer.
      final known = state.contacts.map((c) => c.id).toSet();
      final merged = [
        ...state.contacts,
        ...newContacts.where((c) => !known.contains(c.id)),
      ];
      emit(state.copyWith(
        contacts: merged,
        page: nextPage,
        isLoadingMore: false,
      ));
    } on AppException {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() => loadInitial();

  void search(String query) {
    emit(state.copyWith(query: query.trim()));
  }

  Future<void> setGender(String? gender) async {
    emit(state.copyWith(filters: state.filters.copyWith(gender: () => gender)));
    await loadInitial();
  }

  Future<void> setNationality(String? nationality) async {
    emit(state.copyWith(
      filters: state.filters.copyWith(nationality: () => nationality),
    ));
    await loadInitial();
  }

  Future<void> clearFilters() async {
    if (state.filters.isEmpty) return;
    emit(state.copyWith(filters: const ContactFilters()));
    await loadInitial();
  }
}
