import 'package:bloc_test/bloc_test.dart';
import 'package:contacts_app/core/errors/app_exception.dart';
import 'package:contacts_app/domain/entities/contact.dart';
import 'package:contacts_app/domain/repositories/contact_repository.dart';
import 'package:contacts_app/presentation/contacts/cubit/contacts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockContactRepository extends Mock implements ContactRepository {}

Contact buildContact(int index) {
  return Contact(
    id: 'id-$index',
    firstName: 'First$index',
    lastName: 'Last$index',
    gender: 'female',
    nationality: 'FR',
    email: 'user$index@example.com',
    phone: '01 00 00 00 0$index',
    cell: '06 00 00 00 0$index',
    thumbnailUrl: '',
    pictureUrl: '',
    street: '1 rue de la Paix',
    city: 'Paris',
    state: 'Île-de-France',
    country: 'France',
    age: 30,
  );
}

void main() {
  late MockContactRepository repository;

  setUpAll(() {
    registerFallbackValue(const ContactFilters());
  });

  setUp(() {
    repository = MockContactRepository();
  });

  ContactsCubit buildCubit() => ContactsCubit(repository);

  group('loadInitial', () {
    final contacts = List.generate(50, buildContact);

    blocTest<ContactsCubit, ContactsState>(
      'emits [loading, success] with 50 contacts',
      build: () {
        when(() => repository.fetchContacts(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filters: any(named: 'filters'),
            )).thenAnswer((_) async => contacts);
        return buildCubit();
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const ContactsState(status: ContactsStatus.loading),
        isA<ContactsState>()
            .having((s) => s.status, 'status', ContactsStatus.success)
            .having((s) => s.contacts.length, 'contacts', 50)
            .having((s) => s.page, 'page', 2),
      ],
      verify: (_) {
        verify(() => repository.fetchContacts(
              page: 1,
              pageSize: ContactsCubit.initialPageSize,
              filters: any(named: 'filters'),
            )).called(1);
      },
    );

    blocTest<ContactsCubit, ContactsState>(
      'emits [loading, failure] when the repository throws',
      build: () {
        when(() => repository.fetchContacts(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filters: any(named: 'filters'),
            )).thenThrow(const AppException('Erreur réseau'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const ContactsState(status: ContactsStatus.loading),
        isA<ContactsState>()
            .having((s) => s.status, 'status', ContactsStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Erreur réseau'),
      ],
    );
  });

  group('loadMore', () {
    final initial = List.generate(50, buildContact);

    ContactsState successState() => ContactsState(
          status: ContactsStatus.success,
          contacts: initial,
          page: 2,
        );

    blocTest<ContactsCubit, ContactsState>(
      'appends the next page and de-duplicates known contacts',
      build: () {
        when(() => repository.fetchContacts(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filters: any(named: 'filters'),
            )).thenAnswer(
          // La page 3 renvoie un doublon (id-0) et 24 nouveaux contacts.
          (_) async => [buildContact(0), ...List.generate(24, (i) => buildContact(100 + i))],
        );
        return buildCubit();
      },
      seed: successState,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<ContactsState>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<ContactsState>()
            .having((s) => s.contacts.length, 'contacts', 74)
            .having((s) => s.page, 'page', 3)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
    );

    blocTest<ContactsCubit, ContactsState>(
      'keeps the loaded list and flags the failure when the next page fails',
      build: () {
        when(() => repository.fetchContacts(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filters: any(named: 'filters'),
            )).thenThrow(const AppException('Erreur réseau'));
        return buildCubit();
      },
      seed: successState,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<ContactsState>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<ContactsState>()
            .having((s) => s.loadMoreFailed, 'loadMoreFailed', true)
            .having((s) => s.contacts.length, 'contacts kept', 50),
      ],
    );

    blocTest<ContactsCubit, ContactsState>(
      'ignores concurrent calls while a fetch is in flight',
      build: () {
        when(() => repository.fetchContacts(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filters: any(named: 'filters'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return List.generate(25, (i) => buildContact(200 + i));
        });
        return buildCubit();
      },
      seed: successState,
      act: (cubit) async {
        await Future.wait([cubit.loadMore(), cubit.loadMore()]);
      },
      verify: (_) {
        verify(() => repository.fetchContacts(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filters: any(named: 'filters'),
            )).called(1);
      },
    );
  });

  group('search', () {
    test('visibleContacts filters by name, email and city locally', () {
      final state = ContactsState(
        status: ContactsStatus.success,
        contacts: [
          buildContact(1),
          buildContact(2),
        ],
        query: 'first1',
      );

      expect(state.visibleContacts.length, 1);
      expect(state.visibleContacts.first.firstName, 'First1');
    });
  });
}
