import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project_admin_dashboard/core/constants.dart';

class PatientAnalyticsPage extends StatelessWidget {
  const PatientAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64.r, color: AppConstants.primary),
          SizedBox(height: 16.h),
          Text(
            'Patient Analytics',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppConstants.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Analytics dashboard is coming soon.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
