import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_data_source.dart';

class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._remoteDataSource);

  final ContactRemoteDataSource _remoteDataSource;

  @override
  Future<List<Contact>> fetchContacts({
    required int page,
    required int pageSize,
    ContactFilters filters = const ContactFilters(),
  }) async {
    try {
      return await _remoteDataSource.fetchContacts(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    } on FormatException {
      throw const AppException('Réponse du serveur invalide.');
    }
  }
}
