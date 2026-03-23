import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? specialization;
  final String? bio;
  final int? yearsOfExperience;
  final String? clinicAddress;
  final String? licenseNumber;
  final String? hospital;
  final bool isApproved;
  final double? averageRating;
  final int totalReviews;
  final DateTime createdAt;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.bio,
    required this.yearsOfExperience,
    required this.clinicAddress,
    required this.licenseNumber,
    required this.hospital,
    required this.isApproved,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      specialization: json['specialization'],
      bio: json['bio'],
      yearsOfExperience: json['yearsOfExperience'],
      clinicAddress: json['clinicAddress'],
      licenseNumber: json['licenseNumber'],
      hospital: json['hospital'],
      isApproved: json['isApproved'] == true,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'fullName': fullName,
        'phone': phone,
        'specialization': specialization,
        'bio': bio,
        'yearsOfExperience': yearsOfExperience,
        'clinicAddress': clinicAddress,
        'hospital': hospital,
      };

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        specialization,
        bio,
        yearsOfExperience,
        clinicAddress,
        licenseNumber,
        hospital,
        isApproved,
        averageRating,
        totalReviews,
        createdAt,
      ];
}
