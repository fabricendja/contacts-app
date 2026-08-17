import 'package:contacts_app/data/models/contact_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleJson = {
    'gender': 'female',
    'name': {'title': 'Miss', 'first': 'Jennie', 'last': 'Nichols'},
    'location': {
      'street': {'number': 8929, 'name': 'Valwood Pkwy'},
      'city': 'Billings',
      'state': 'Michigan',
      'country': 'United States',
    },
    'email': 'jennie.nichols@example.com',
    'login': {'uuid': '7a0eed16-9430-4d68-901f-c0d4c1c3bf00'},
    'dob': {'date': '1992-03-08T15:13:16.688Z', 'age': 30},
    'phone': '(272) 790-0888',
    'cell': '(489) 330-2385',
    'nat': 'US',
    'picture': {
      'large': 'https://randomuser.me/api/portraits/women/75.jpg',
      'medium': 'https://randomuser.me/api/portraits/med/women/75.jpg',
    },
  };

  group('ContactModel.fromJson', () {
    test('parses a full randomuser payload', () {
      final contact = ContactModel.fromJson(sampleJson);

      expect(contact.id, '7a0eed16-9430-4d68-901f-c0d4c1c3bf00');
      expect(contact.firstName, 'Jennie');
      expect(contact.lastName, 'Nichols');
      expect(contact.fullName, 'Jennie Nichols');
      expect(contact.gender, 'female');
      expect(contact.nationality, 'US');
      expect(contact.email, 'jennie.nichols@example.com');
      expect(contact.phone, '(272) 790-0888');
      expect(contact.cell, '(489) 330-2385');
      expect(contact.street, '8929 Valwood Pkwy');
      expect(contact.city, 'Billings');
      expect(contact.country, 'United States');
      expect(contact.age, 30);
      expect(
        contact.pictureUrl,
        'https://randomuser.me/api/portraits/women/75.jpg',
      );
    });

    test('tolerates missing fields without throwing', () {
      final contact = ContactModel.fromJson(const {'gender': 'male'});

      expect(contact.id, isEmpty);
      expect(contact.fullName.trim(), isEmpty);
      expect(contact.age, 0);
    });

    test('survives a toJson / fromJson round trip', () {
      final original = ContactModel.fromJson(sampleJson);
      final restored = ContactModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.fullName, original.fullName);
      expect(restored.email, original.email);
      expect(restored.street, original.street);
      expect(restored.age, original.age);
    });
  });
}
