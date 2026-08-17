import '../entities/contact.dart';

/// Filtres pris en charge côté serveur par randomuser.me.
class ContactFilters {
  const ContactFilters({this.gender, this.nationality});

  final String? gender; // 'male' | 'female'
  final String? nationality; // code ISO, ex. 'fr'

  bool get isEmpty => gender == null && nationality == null;

  ContactFilters copyWith({
    String? Function()? gender,
    String? Function()? nationality,
  }) {
    return ContactFilters(
      gender: gender != null ? gender() : this.gender,
      nationality: nationality != null ? nationality() : this.nationality,
    );
  }
}

abstract class ContactRepository {
  Future<List<Contact>> fetchContacts({
    required int page,
    required int pageSize,
    ContactFilters filters,
  });
}
