import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants.dart';
import '../../../widgets/custom_toast.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.background,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -100.h,
            right: -100.w,
            child: Container(
              width: 400.w,
              height: 400.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -50.w,
            child: Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 440.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand / Logo area
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppConstants.primary,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primary.withValues(alpha: 0.3),
                            blurRadius: 20.r,
                            offset: Offset(0, 10.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 48.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Staff Portal',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your credentials to access the dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Login Card
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state.status == AuthStatus.error &&
                            state.message != null) {
                          CustomToast.show(
                            context,
                            state.message!,
                            isError: true,
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(32.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 40.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'admin@hospital.com',
                                    icon: Icons.alternate_email_rounded,
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // Submit Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading =
                                    state.status == AuthStatus.loading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 24.w,
                                            height: 24.h,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Access Dashboard',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      '© 2026 GradProject Health Systems. All rights reserved.',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppConstants.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 15.sp,
                color: AppConstants.outlineVariant,
                fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, size: 20.sp, color: AppConstants.outline),
            filled: true,
            fillColor: AppConstants.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  const BorderSide(color: AppConstants.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.all(18.w),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
