import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project_admin_dashboard/core/constants.dart';
import 'package:graduation_project_admin_dashboard/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:graduation_project_admin_dashboard/models/statistics.dart';
import '../../../core/app_section.dart';
import '../../../widgets/responsive_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../bookings/ui/bookings_page.dart';
import '../../dashboard/ui/dashboard_page.dart';
import '../../doctors/ui/doctors_page.dart';
import '../../patients/ui/patients_page.dart';
import '../../patients/ui/patient_analytics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppSection _section = AppSection.dashboard;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      selected: _section,
      onSelect: (section) => setState(() => _section = section),
      onLogout: () => context.read<AuthBloc>().add(const LogoutRequested()),
      child: Column(
        children: [
          _TopBar(title: _section.title),
          Expanded(child: _buildSection()),
        ],
      ),
    );
  }

  Widget _buildSection() {
    switch (_section) {
      case AppSection.dashboard:
        return const DashboardPage();
      case AppSection.doctors:
        return const DoctorsPage();
      case AppSection.patients:
        return const PatientsPage();
      case AppSection.patientAnalytics:
        return const PatientAnalyticsPage();
      case AppSection.bookings:
        return const BookingsPage();
    }
  }
}

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceContainerLow,
      ),
      child: Row(
        children: [
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false)
            IconButton(
              icon: Icon(Icons.menu, color: AppConstants.primary, size: 24.sp),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          SizedBox(width: 8.w),
          Text(
            'GradProject',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppConstants.primary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Search Bar
          Container(
            width: 300.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppConstants.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search analytics...',
                hintStyle: TextStyle(
                    color: AppConstants.outlineVariant, fontSize: 13.sp),
                prefixIcon: Icon(Icons.search,
                    color: AppConstants.outline, size: 20.sp),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(width: 24.w),
          // Notifications
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              final alerts = state.stats?.alerts ?? [];
              final hasNotifications = alerts.isNotEmpty;

              return PopupMenuButton<DashboardAlert>(
                offset: Offset(0, 48.h),
                icon: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_outlined,
                          size: 24.sp, color: AppConstants.textSecondary),
                    ),
                    if (hasNotifications)
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(
                            color: AppConstants.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                itemBuilder: (context) {
                  if (alerts.isEmpty) {
                    return [
                      PopupMenuItem(
                        enabled: false,
                        child: Text('No new notifications',
                            style: TextStyle(fontSize: 12.sp)),
                      )
                    ];
                  }
                  return alerts.map((alert) {
                    return PopupMenuItem(
                      value: alert,
                      child: Row(
                        children: [
                          Icon(
                            alert.type == 'warning'
                                ? Icons.warning
                                : alert.type == 'error'
                                    ? Icons.error
                                    : Icons.info,
                            size: 16.sp,
                            color: alert.type == 'warning'
                                ? Colors.orange
                                : alert.type == 'error'
                                    ? Colors.red
                                    : Colors.blue,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.title,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(alert.message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            },
          ),
          SizedBox(width: 16.w),
          // User Profile
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Admin',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primary),
                  ),
                  Text(
                    'Admin',
                    style: TextStyle(
                        fontSize: 10.sp, color: AppConstants.textSecondary),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 20.r,
                backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBoIfzH2YZP_zGoGd9UjmtjgUbSIbR2NuVbrCrpVKIWKmO6J3Y3vrMTrpAiPZ-hwHJLk-tE6RCwGWQBb3tsXRlfnFB_QHDe5dAET_Ny9DT84C1HlSsNiVt_WZc3lt6-8xco-o1FTfi8iMccj_fpmggPhC7PWX2yOT8oE7Dc8rI0x3KsVz-546_LVTFA8Eh1YYw5Cw8BcRYKkwW0FnUVyjbjSXLdBk3XXQS6DxApjV8eSnF9ZlMVRnYQkrTNTQpKLMB0FvVnUmx-hyc'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
