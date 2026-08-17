import '../../domain/entities/contact.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.gender,
    required super.nationality,
    required super.email,
    required super.phone,
    required super.cell,
    required super.thumbnailUrl,
    required super.pictureUrl,
    required super.street,
    required super.city,
    required super.state,
    required super.country,
    required super.age,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>? ?? const {};
    final picture = json['picture'] as Map<String, dynamic>? ?? const {};
    final location = json['location'] as Map<String, dynamic>? ?? const {};
    final street = location['street'] as Map<String, dynamic>? ?? const {};
    final login = json['login'] as Map<String, dynamic>? ?? const {};
    final dob = json['dob'] as Map<String, dynamic>? ?? const {};

    return ContactModel(
      id: login['uuid'] as String? ?? '',
      firstName: name['first'] as String? ?? '',
      lastName: name['last'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      nationality: json['nat'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      cell: json['cell'] as String? ?? '',
      thumbnailUrl: picture['medium'] as String? ?? '',
      pictureUrl: picture['large'] as String? ?? '',
      street: '${street['number'] ?? ''} ${street['name'] ?? ''}'.trim(),
      city: location['city'] as String? ?? '',
      state: location['state'] as String? ?? '',
      country: location['country'] as String? ?? '',
      age: dob['age'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': {'uuid': id},
      'name': {'first': firstName, 'last': lastName},
      'gender': gender,
      'nat': nationality,
      'email': email,
      'phone': phone,
      'cell': cell,
      'picture': {'medium': thumbnailUrl, 'large': pictureUrl},
      'location': {
        'street': {'name': street},
        'city': city,
        'state': state,
        'country': country,
      },
      'dob': {'age': age},
    };
  }

  factory ContactModel.fromContact(Contact c) {
    return ContactModel(
      id: c.id,
      firstName: c.firstName,
      lastName: c.lastName,
      gender: c.gender,
      nationality: c.nationality,
      email: c.email,
      phone: c.phone,
      cell: c.cell,
      thumbnailUrl: c.thumbnailUrl,
      pictureUrl: c.pictureUrl,
      street: c.street,
      city: c.city,
      state: c.state,
      country: c.country,
      age: c.age,
    );
  }
}
