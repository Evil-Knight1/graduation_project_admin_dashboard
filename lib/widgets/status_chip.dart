import 'package:flutter/material.dart';
import '../models/appointment.dart';

class StatusChip extends StatelessWidget {
  final AppointmentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case AppointmentStatus.confirmed:
        color = const Color(0xFF2EAE72);
        break;
      case AppointmentStatus.cancelled:
        color = const Color(0xFFE05757);
        break;
      case AppointmentStatus.pending:
      default:
        color = const Color(0xFFF0A93B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
