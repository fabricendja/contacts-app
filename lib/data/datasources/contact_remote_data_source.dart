import '../../core/network/api_client.dart';
import '../../domain/repositories/contact_repository.dart';
import '../models/contact_model.dart';

class ContactRemoteDataSource {
  ContactRemoteDataSource(this._client);

  final ApiClient _client;

  /// randomuser.me ne renvoie des pages stables qu'avec un seed, sinon
  /// chaque page contient de nouveaux utilisateurs aléatoires (doublons).
  /// Subtilité : le seed écrase `gender` et `nat`, il faut donc le retirer
  /// dès qu'un filtre est actif (le cubit déduplique alors par uuid).
  static const String _seed = 'capcoding';

  static const String _includedFields =
      'login,name,gender,nat,email,phone,cell,picture,location,dob';

  Future<List<ContactModel>> fetchContacts({
    required int page,
    required int pageSize,
    ContactFilters filters = const ContactFilters(),
  }) async {
    final data = await _client.get(
      '',
      queryParameters: {
        'page': page,
        'results': pageSize,
        if (filters.isEmpty) 'seed': _seed,
        'inc': _includedFields,
        if (filters.gender != null) 'gender': filters.gender,
        if (filters.nationality != null) 'nat': filters.nationality,
      },
    );

    final results = data['results'] as List<dynamic>? ?? const [];
    return results
        .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
