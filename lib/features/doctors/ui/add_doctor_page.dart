import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as PhoneValidator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart';
import '../../../core/constants.dart';
import '../bloc/doctors_bloc.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phoneController = PhoneController(null);
  final _password = TextEditingController();
  final _license = TextEditingController();
  final _bio = TextEditingController();
  final _years = TextEditingController();
  final _clinic = TextEditingController();
  final _hospital = TextEditingController();

  final Set<String> _selectedSpecializations = {};

  @override
  void initState() {
    super.initState();
    context.read<DoctorsBloc>().add(SpecializationsFetched());
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phoneController.dispose();
    _password.dispose();
    _license.dispose();
    _bio.dispose();
    _years.dispose();
    _clinic.dispose();
    _hospital.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final phoneNumber = _phoneController.value;
    if (phoneNumber == null) return;

    context.read<DoctorsBloc>().add(
          DoctorCreated(
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: phoneNumber.international,
            password: _password.text.trim(),
            licenseNumber: _license.text.trim(),
            specializations: _selectedSpecializations.toList(),
            bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
            yearsOfExperience: int.tryParse(_years.text.trim()),
            clinicAddress:
                _clinic.text.trim().isEmpty ? null : _clinic.text.trim(),
            hospital:
                _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorsBloc, DoctorsState>(
      listener: (context, state) {
        if (!state.actionInProgress &&
            state.message == null &&
            state.status == DoctorsStatus.loaded) {
          // Success!
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Doctor'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 800.w),
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor Information',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _fullName,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _email,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone Number',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 8.h),
                              PhoneFormField(
                                controller: _phoneController,
                                defaultCountry: "EG",
                                decoration: InputDecoration(
                                  hintText: 'Mobile Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _password,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _license,
                            label: 'License Number',
                            icon: Icons.badge_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _years,
                            label: 'Years of Experience',
                            icon: Icons.timeline,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Specializations',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    BlocBuilder<DoctorsBloc, DoctorsState>(
                      builder: (context, state) {
                        return Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: state.specializations.map((s) {
                            final isSelected =
                                _selectedSpecializations.contains(s);
                            return FilterChip(
                              label: Text(s),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedSpecializations.add(s);
                                  } else {
                                    _selectedSpecializations.remove(s);
                                  }
                                });
                              },
                              selectedColor:
                                  AppConstants.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppConstants.primary,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    if (_selectedSpecializations.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text('Please select at least one specialization',
                            style:
                                TextStyle(color: Colors.red, fontSize: 12.sp)),
                      ),
                    SizedBox(height: 24.h),
                    _buildTextField(
                      controller: _bio,
                      label: 'Professional Bio',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _clinic,
                            label: 'Clinic Address',
                            icon: Icons.location_city,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _hospital,
                            label: 'Hospital Name',
                            icon: Icons.local_hospital_outlined,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: BlocBuilder<DoctorsBloc, DoctorsState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.actionInProgress ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: state.actionInProgress
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text('Create Doctor Account',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20.r),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
