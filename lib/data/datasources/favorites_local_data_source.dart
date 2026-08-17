import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/contact.dart';
import '../models/contact_model.dart';

/// Stocke les contacts favoris en local, en entier : la liste survit ainsi
/// aux redémarrages alors que l'API renvoie des données aléatoires.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'favorite_contacts';

  List<ContactModel> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> save(List<Contact> contacts) async {
    final payload = contacts
        .map((c) => ContactModel.fromContact(c).toJson())
        .toList();
    await _prefs.setString(_key, jsonEncode(payload));
  }
}
