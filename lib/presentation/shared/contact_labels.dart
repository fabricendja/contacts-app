import '../../domain/entities/contact.dart';

/// Libellés d'affichage dérivés du contact (couche présentation :
/// l'entité du domaine reste neutre, sans texte en dur).
extension ContactLabels on Contact {
  bool get isFemale => gender.toLowerCase() == 'female';

  /// Civilité déduite du genre renvoyé par l'API.
  String get honorific => isFemale ? 'Mme' : 'M.';

  /// Ex. « M. Jean Dupont » / « Mme Marie Dupont ».
  String get displayName => '$honorific $fullName';

  String get genderLabel => isFemale ? 'Féminin' : 'Masculin';
}
