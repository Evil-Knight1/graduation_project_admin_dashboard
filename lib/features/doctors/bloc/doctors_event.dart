part of 'doctors_bloc.dart';

abstract class DoctorsEvent extends Equatable {
  const DoctorsEvent();

  @override
  List<Object?> get props => [];
}

class DoctorsFetched extends DoctorsEvent {
  final int pageNumber;
  final int pageSize;

  const DoctorsFetched({required this.pageNumber, required this.pageSize});

  @override
  List<Object?> get props => [pageNumber, pageSize];
}

class DoctorsPageChanged extends DoctorsEvent {
  final int pageNumber;
  final int pageSize;

  const DoctorsPageChanged({required this.pageNumber, required this.pageSize});

  @override
  List<Object?> get props => [pageNumber, pageSize];
}

class DoctorApproved extends DoctorsEvent {
  final int id;
  const DoctorApproved(this.id);

  @override
  List<Object?> get props => [id];
}

class DoctorRejected extends DoctorsEvent {
  final int id;
  const DoctorRejected(this.id);

  @override
  List<Object?> get props => [id];
}

class DoctorDeleted extends DoctorsEvent {
  final int id;
  const DoctorDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class DoctorCreated extends DoctorsEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String licenseNumber;
  final String? specialization;
  final String? bio;
  final int? yearsOfExperience;
  final String? clinicAddress;
  final String? hospital;

  const DoctorCreated({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.licenseNumber,
    this.specialization,
    this.bio,
    this.yearsOfExperience,
    this.clinicAddress,
    this.hospital,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        password,
        licenseNumber,
        specialization,
        bio,
        yearsOfExperience,
        clinicAddress,
        hospital,
      ];
}

class DoctorUpdated extends DoctorsEvent {
  final Doctor doctor;
  const DoctorUpdated(this.doctor);

  @override
  List<Object?> get props => [doctor];
}
