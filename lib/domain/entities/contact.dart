import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.nationality,
    required this.email,
    required this.phone,
    required this.cell,
    required this.thumbnailUrl,
    required this.pictureUrl,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.age,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final String nationality;
  final String email;
  final String phone;
  final String cell;
  final String thumbnailUrl;
  final String pictureUrl;
  final String street;
  final String city;
  final String state;
  final String country;
  final int age;

  String get fullName => '$firstName $lastName';

  String get fullAddress => '$street\n$city, $state\n$country';

  @override
  List<Object?> get props => [id, email];
}
