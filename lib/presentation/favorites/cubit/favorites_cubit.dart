import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/favorites_local_data_source.dart';
import '../../../domain/entities/contact.dart';

class FavoritesCubit extends Cubit<List<Contact>> {
  FavoritesCubit(this._localDataSource) : super(const []) {
    emit(_localDataSource.load());
  }

  final FavoritesLocalDataSource _localDataSource;

  bool isFavorite(Contact contact) => state.any((c) => c.id == contact.id);

  Future<void> toggle(Contact contact) async {
    final updated = isFavorite(contact)
        ? state.where((c) => c.id != contact.id).toList()
        : [...state, contact];
    emit(updated);
    await _localDataSource.save(updated);
  }
}
