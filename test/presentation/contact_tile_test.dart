import 'package:contacts_app/domain/entities/contact.dart';
import 'package:contacts_app/presentation/contacts/widgets/contact_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const contact = Contact(
    id: 'abc',
    firstName: 'Marie',
    lastName: 'Dupont',
    gender: 'female',
    nationality: 'FR',
    email: 'marie.dupont@example.com',
    phone: '01 23 45 67 89',
    cell: '06 12 34 56 78',
    thumbnailUrl: '',
    pictureUrl: '',
    street: '12 rue Victor Hugo',
    city: 'Lyon',
    state: 'Rhône',
    country: 'France',
    age: 34,
  );

  testWidgets('displays the contact name, location and reacts to tap',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContactTile(
            contact: contact,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // La civilité est déduite du genre (female → Mme, male → M.).
    expect(find.text('Mme Marie Dupont'), findsOneWidget);
    expect(find.text('Lyon, France'), findsOneWidget);

    await tester.tap(find.byType(ContactTile));
    expect(tapped, isTrue);
  });

  testWidgets('shows a favorite badge when isFavorite is true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContactTile(
            contact: contact,
            isFavorite: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });
}
