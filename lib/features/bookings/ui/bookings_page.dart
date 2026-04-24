import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project_admin_dashboard/core/constants.dart';
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
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointments',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              if (state.status == AppointmentsStatus.updating)
                LinearProgressIndicator(minHeight: 2.h),
              SizedBox(height: 8.h),
              Expanded(
                child: state.appointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 64.r, color: AppConstants.outline),
                            SizedBox(height: 16.h),
                            Text(
                              'No appointments found',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : isDesktop
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
                                DataCell(
                                    StatusChip(status: appointment.status)),
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
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: appointment.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: appointment.status.color.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppointmentStatus>(
          value: appointment.status,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18.r, color: appointment.status.color),
          elevation: 8,
          style: TextStyle(
            color: appointment.status.color,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}
