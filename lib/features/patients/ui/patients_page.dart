import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project_admin_dashboard/core/constants.dart';
import 'package:graduation_project_admin_dashboard/models/patient.dart';
import 'package:graduation_project_admin_dashboard/widgets/error_view.dart';
import 'package:graduation_project_admin_dashboard/widgets/loading_view.dart';
import '../bloc/patients_bloc.dart';
import '../bloc/patients_event.dart';
import '../bloc/patients_state.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientsBloc>().add(const LoadPatients());
  }

  @override
  Widget build(BuildContext context) {
    return const _PatientsView();
  }
}

class _PatientsView extends StatelessWidget {
  const _PatientsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Patients Management',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    context.read<PatientsBloc>().add(const LoadPatients()),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: BlocConsumer<PatientsBloc, PatientsState>(
              listener: (context, state) {
                if (state is PatientOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is PatientsLoading) {
                  return const LoadingView();
                }
                if (state is PatientsError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<PatientsBloc>().add(const LoadPatients()),
                  );
                }
                if (state is PatientsLoaded) {
                  if (state.result.items.isEmpty) {
                    return _buildEmptyState();
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _PatientsTable(
                          patients: state.result.items,
                          totalCount: state.result.totalCount,
                          pageNumber: state.result.pageNumber,
                          pageSize: state.result.pageSize,
                          onPageChanged: (page, size) => context
                              .read<PatientsBloc>()
                              .add(LoadPatients(pageNumber: page, pageSize: size)),
                          onDelete: (id) => _confirmDelete(context, id),
                        );
                      } else {
                        return _PatientsList(
                          patients: state.result.items,
                          totalCount: state.result.totalCount,
                          pageNumber: state.result.pageNumber,
                          pageSize: state.result.pageSize,
                          onPageChanged: (page, size) => context
                              .read<PatientsBloc>()
                              .add(LoadPatients(pageNumber: page, pageSize: size)),
                          onDelete: (id) => _confirmDelete(context, id),
                        );
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined,
              size: 64.r, color: AppConstants.outline),
          SizedBox(height: 16.h),
          Text(
            'No patients found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text('Are you sure you want to delete this patient?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<PatientsBloc>().add(DeletePatientRequested(id));
    }
  }
}

class _PatientsTable extends StatelessWidget {
  final List<Patient> patients;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final void Function(int pageNumber, int pageSize) onPageChanged;
  final void Function(int id) onDelete;

  const _PatientsTable({
    required this.patients,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.onPageChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final start = (pageNumber - 1) * pageSize + 1;
    final end = (start + patients.length - 1).clamp(0, totalCount);
    final hasNext = pageNumber * pageSize < totalCount;
    final hasPrevious = pageNumber > 1;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppConstants.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppConstants.outlineVariant),
              ),
              child: DataTable(
                horizontalMargin: 24.w,
                columnSpacing: 24.w,
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Blood Type')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: patients.map((patient) {
                  return DataRow(cells: [
                    DataCell(Text(patient.fullName)),
                    DataCell(Text(patient.email)),
                    DataCell(Text(patient.phone)),
                    DataCell(Text(patient.bloodType ?? 'N/A')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => onDelete(patient.id),
                            icon: const Icon(Icons.delete_outline),
                            color: AppConstants.error,
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Text('Showing $start-$end of $totalCount',
                style: TextStyle(fontSize: 13.sp)),
            const Spacer(),
            DropdownButton<int>(
              value: pageSize,
              items: const [5, 10, 20]
                  .map((size) =>
                      DropdownMenuItem(value: size, child: Text('$size rows')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onPageChanged(1, value);
                }
              },
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: hasPrevious
                  ? () => onPageChanged(pageNumber - 1, pageSize)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: hasNext
                  ? () => onPageChanged(pageNumber + 1, pageSize)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _PatientsList extends StatelessWidget {
  final List<Patient> patients;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final void Function(int pageNumber, int pageSize) onPageChanged;
  final void Function(int id) onDelete;

  const _PatientsList({
    required this.patients,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.onPageChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasNext = pageNumber * pageSize < totalCount;
    final hasPrevious = pageNumber > 1;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: patients.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                child: ListTile(
                  title: Text(patient.fullName,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  subtitle: Text('${patient.email} \u2022 ${patient.phone}',
                      style: TextStyle(fontSize: 12.sp)),
                  trailing: IconButton(
                    onPressed: () => onDelete(patient.id),
                    icon: const Icon(Icons.delete_outline),
                    color: AppConstants.error,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            DropdownButton<int>(
              value: pageSize,
              items: const [5, 10, 20]
                  .map((size) =>
                      DropdownMenuItem(value: size, child: Text('$size rows')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onPageChanged(1, value);
                }
              },
            ),
            const Spacer(),
            IconButton(
              onPressed: hasPrevious
                  ? () => onPageChanged(pageNumber - 1, pageSize)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: hasNext
                  ? () => onPageChanged(pageNumber + 1, pageSize)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}
