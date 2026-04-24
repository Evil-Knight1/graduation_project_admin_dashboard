import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.gender,
    this.dateOfBirth,
    this.bloodType,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'],
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? ''),
      bloodType: json['bloodType'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        gender,
        dateOfBirth,
        bloodType,
        createdAt,
      ];
}
