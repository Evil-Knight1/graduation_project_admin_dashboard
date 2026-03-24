import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive.dart';
import '../../../models/appointment.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/loading_view.dart';
import '../../../widgets/status_chip.dart';
import '../bloc/appointments_bloc.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentsBloc>().add(const AppointmentsFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      builder: (context, state) {
        if (state.status == AppointmentsStatus.loading) {
          return const LoadingView();
        }

        if (state.status == AppointmentsStatus.error) {
          return ErrorView(
            message: state.message ?? 'Failed to load bookings',
            onRetry: () => context
                .read<AppointmentsBloc>()
                .add(const AppointmentsFetched()),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final isDesktop = Responsive.isDesktop(width);
        final formatter = DateFormat('MMM dd, HH:mm');

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (state.status == AppointmentsStatus.updating)
                const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 8),
              Expanded(
                child: isDesktop
                    ? DataTable(
                        columns: const [
                          DataColumn(label: Text('Patient')),
                          DataColumn(label: Text('Doctor')),
                          DataColumn(label: Text('Time')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: state.appointments.map((appointment) {
                          return DataRow(cells: [
                            DataCell(Text(appointment.patientName)),
                            DataCell(Text(appointment.doctorName)),
                            DataCell(Text(
                              '${formatter.format(appointment.startTime)} - ${formatter.format(appointment.endTime)}',
                            )),
                            DataCell(StatusChip(status: appointment.status)),
                            DataCell(_StatusAction(
                              appointment: appointment,
                              onChanged: (status) {
                                context.read<AppointmentsBloc>().add(
                                      AppointmentStatusChanged(
                                        id: appointment.id,
                                        status: status,
                                      ),
                                    );
                              },
                            )),
                          ]);
                        }).toList(),
                      )
                    : ListView.separated(
                        itemCount: state.appointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final appointment = state.appointments[index];
                          return Card(
                            child: ListTile(
                              title: Text(appointment.patientName),
                              subtitle: Text(
                                '${appointment.doctorName}\n${formatter.format(appointment.startTime)}',
                              ),
                              isThreeLine: true,
                              trailing: _StatusAction(
                                appointment: appointment,
                                onChanged: (status) {
                                  context.read<AppointmentsBloc>().add(
                                        AppointmentStatusChanged(
                                          id: appointment.id,
                                          status: status,
                                        ),
                                      );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusAction extends StatelessWidget {
  final Appointment appointment;
  final ValueChanged<AppointmentStatus> onChanged;

  const _StatusAction({required this.appointment, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AppointmentStatus>(
      value: appointment.status,
      underline: const SizedBox.shrink(),
      items: AppointmentStatus.values
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
