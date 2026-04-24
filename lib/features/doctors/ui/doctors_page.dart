import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../models/doctor.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/loading_view.dart';
import '../../../widgets/custom_toast.dart';
import '../bloc/doctors_bloc.dart';
import 'add_doctor_page.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<DoctorsBloc>()
        .add(const DoctorsFetched(pageNumber: 1, pageSize: 10));
  }

  void _openCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDoctorPage()),
    );
  }

  void _openEditDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => _DoctorEditDialog(
        doctor: doctor,
        onSubmit: (updated) {
          context.read<DoctorsBloc>().add(DoctorUpdated(updated));
        },
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: const Text('Are you sure you want to delete this doctor?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DoctorsBloc>().add(DoctorDeleted(id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorsBloc, DoctorsState>(
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          CustomToast.show(
            context,
            state.message!,
            isError: state.status == DoctorsStatus.error,
          );
        }
      },
      builder: (context, state) {
        if (state.status == DoctorsStatus.loading) {
          return const LoadingView();
        }
        if (state.status == DoctorsStatus.error) {
          return ErrorView(
            message: state.message ?? 'Failed to load doctors',
            onRetry: () => context.read<DoctorsBloc>().add(DoctorsFetched(
                pageNumber: state.pageNumber, pageSize: state.pageSize)),
          );
        }

        final width = MediaQuery.sizeOf(context).width;
        final isDesktop = Responsive.isDesktop(width);

        return Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Doctors',
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCreatePage,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Doctor'),
                  )
                ],
              ),
              SizedBox(height: 16.h),
              if (state.actionInProgress)
                LinearProgressIndicator(minHeight: 2.h),
              SizedBox(height: 8.h),
              Expanded(
                child: state.doctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 64.r, color: AppConstants.outline),
                            SizedBox(height: 16.h),
                            Text(
                              'No doctors found',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : isDesktop
                        ? _DoctorsTable(
                            doctors: state.doctors,
                            totalCount: state.totalCount,
                            pageNumber: state.pageNumber,
                            pageSize: state.pageSize,
                            onPageChanged: (pageNumber, pageSize) {
                              context.read<DoctorsBloc>().add(
                                    DoctorsPageChanged(
                                        pageNumber: pageNumber,
                                        pageSize: pageSize),
                                  );
                            },
                            onApprove: (id) => context
                                .read<DoctorsBloc>()
                                .add(DoctorApproved(id)),
                            onReject: (id) => context
                                .read<DoctorsBloc>()
                                .add(DoctorRejected(id)),
                            onEdit: _openEditDialog,
                            onDelete: _confirmDelete,
                          )
                        : _DoctorsList(
                            doctors: state.doctors,
                            totalCount: state.totalCount,
                            pageNumber: state.pageNumber,
                            pageSize: state.pageSize,
                            onPageChanged: (pageNumber, pageSize) {
                              context.read<DoctorsBloc>().add(
                                    DoctorsPageChanged(
                                        pageNumber: pageNumber,
                                        pageSize: pageSize),
                                  );
                            },
                            onApprove: (id) => context
                                .read<DoctorsBloc>()
                                .add(DoctorApproved(id)),
                            onReject: (id) => context
                                .read<DoctorsBloc>()
                                .add(DoctorRejected(id)),
                            onEdit: _openEditDialog,
                            onDelete: _confirmDelete,
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoctorsTable extends StatelessWidget {
  final List<Doctor> doctors;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final void Function(int pageNumber, int pageSize) onPageChanged;
  final void Function(int id) onApprove;
  final void Function(int id) onReject;
  final void Function(Doctor doctor) onEdit;
  final void Function(int id) onDelete;

  const _DoctorsTable({
    required this.doctors,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.onPageChanged,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final start = ((pageNumber - 1) * pageSize) + 1;
    final end = (pageNumber * pageSize).clamp(1, totalCount);
    final hasNext = pageNumber * pageSize < totalCount;
    final hasPrevious = pageNumber > 1;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Specialization')),
                DataColumn(label: Text('Approved')),
                DataColumn(label: Text('Actions')),
              ],
              rows: doctors.map((doctor) {
                return DataRow(cells: [
                  DataCell(Text(doctor.fullName)),
                  DataCell(Text(doctor.email)),
                  DataCell(Text(doctor.specialization ?? '-')),
                  DataCell(
                    Chip(
                      label: Text(doctor.isApproved ? 'Approved' : 'Pending'),
                      backgroundColor: doctor.isApproved
                          ? const Color(0xFFE6F6EF)
                          : const Color(0xFFFFF4DB),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit,
                              color: AppConstants.primary),
                          onPressed: () => onEdit(doctor),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => onDelete(doctor.id),
                        ),
                        if (!doctor.isApproved)
                          TextButton(
                            onPressed: () => onApprove(doctor.id),
                            child: const Text('Approve'),
                          ),
                        if (!doctor.isApproved)
                          TextButton(
                            onPressed: () => onReject(doctor.id),
                            child: const Text('Reject'),
                          ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Text('Showing $start-$end of $totalCount'),
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

class _DoctorsList extends StatelessWidget {
  final List<Doctor> doctors;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final void Function(int pageNumber, int pageSize) onPageChanged;
  final void Function(int id) onApprove;
  final void Function(int id) onReject;
  final void Function(Doctor doctor) onEdit;
  final void Function(int id) onDelete;

  const _DoctorsList({
    required this.doctors,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.onPageChanged,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
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
            itemCount: doctors.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                child: ListTile(
                  title: Text(doctor.fullName),
                  subtitle: Text(
                      '${doctor.email} � ${doctor.specialization ?? 'General'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit(doctor);
                          break;
                        case 'delete':
                          onDelete(doctor.id);
                          break;
                        case 'approve':
                          onApprove(doctor.id);
                          break;
                        case 'reject':
                          onReject(doctor.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                      if (!doctor.isApproved)
                        const PopupMenuItem(
                            value: 'approve', child: Text('Approve')),
                      if (!doctor.isApproved)
                        const PopupMenuItem(
                            value: 'reject', child: Text('Reject')),
                    ],
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


class _DoctorEditDialog extends StatefulWidget {
  final Doctor doctor;
  final void Function(Doctor updated) onSubmit;

  const _DoctorEditDialog({required this.doctor, required this.onSubmit});

  @override
  State<_DoctorEditDialog> createState() => _DoctorEditDialogState();
}

class _DoctorEditDialogState extends State<_DoctorEditDialog> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _specialization;
  late final TextEditingController _bio;
  late final TextEditingController _years;
  late final TextEditingController _clinic;
  late final TextEditingController _hospital;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.doctor.fullName);
    _phone = TextEditingController(text: widget.doctor.phone);
    _specialization =
        TextEditingController(text: widget.doctor.specialization ?? '');
    _bio = TextEditingController(text: widget.doctor.bio ?? '');
    _years = TextEditingController(
      text: widget.doctor.yearsOfExperience?.toString() ?? '',
    );
    _clinic = TextEditingController(text: widget.doctor.clinicAddress ?? '');
    _hospital = TextEditingController(text: widget.doctor.hospital ?? '');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _specialization.dispose();
    _bio.dispose();
    _years.dispose();
    _clinic.dispose();
    _hospital.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = Doctor(
      id: widget.doctor.id,
      fullName: _fullName.text.trim(),
      email: widget.doctor.email,
      phone: _phone.text.trim(),
      specialization: _specialization.text.trim().isEmpty
          ? null
          : _specialization.text.trim(),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      yearsOfExperience: int.tryParse(_years.text.trim()),
      clinicAddress: _clinic.text.trim().isEmpty ? null : _clinic.text.trim(),
      licenseNumber: widget.doctor.licenseNumber,
      hospital: _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
      isApproved: widget.doctor.isApproved,
      averageRating: widget.doctor.averageRating,
      totalReviews: widget.doctor.totalReviews,
      createdAt: widget.doctor.createdAt,
    );
    widget.onSubmit(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Doctor'),
      content: SizedBox(
        width: 520.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _specialization,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _bio,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _years,
                decoration:
                    const InputDecoration(labelText: 'Years of Experience'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _clinic,
                decoration: const InputDecoration(labelText: 'Clinic Address'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _hospital,
                decoration: const InputDecoration(labelText: 'Hospital'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
