import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  pending(0, 'Pending'),
  confirmed(1, 'Confirmed'),
  cancelled(2, 'Cancelled');

  final int value;
  final String label;

  const AppointmentStatus(this.value, this.label);

  static AppointmentStatus fromValue(int? value) {
    return AppointmentStatus.values
        .firstWhere((e) => e.value == value, orElse: () => AppointmentStatus.pending);
  }
}

class Appointment extends Equatable {
  final int id;
  final int patientId;
  final String patientName;
  final int doctorId;
  final String doctorName;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final AppointmentStatus status;
  final bool isPaid;
  final double? amount;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
    required this.isPaid,
    required this.amount,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? 0,
      doctorName: json['doctorName'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      reason: json['reason'] ?? '',
      status: AppointmentStatus.fromValue(json['status']),
      isPaid: json['isPaid'] == true,
      amount: (json['amount'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        doctorId,
        doctorName,
        startTime,
        endTime,
        reason,
        status,
        isPaid,
        amount,
        createdAt,
      ];
}
