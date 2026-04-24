import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project_admin_dashboard/core/app_section.dart';
import 'package:graduation_project_admin_dashboard/core/constants.dart';

class AppSidebar extends StatelessWidget {
  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerLow,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F003D9B),
            blurRadius: 48.r,
            offset: Offset(0, 24.h),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppConstants.primary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.admin_panel_settings,
                      size: 24.r, color: Colors.white),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppConstants.primary,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              children: [
                _NavTile(
                  title: 'Clinical Overview',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  selected: selected == AppSection.dashboard,
                  onTap: () => onSelect(AppSection.dashboard),
                ),
                _NavTile(
                  title: 'Doctors',
                  icon: Icons.group_outlined,
                  selectedIcon: Icons.group,
                  selected: selected == AppSection.doctors,
                  onTap: () => onSelect(AppSection.doctors),
                ),
                _NavTile(
                  title: 'Patients',
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person,
                  selected: selected == AppSection.patients,
                  onTap: () => onSelect(AppSection.patients),
                ),
                _NavTile(
                  title: 'Appointments',
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                  selected: selected == AppSection.bookings,
                  onTap: () => onSelect(AppSection.bookings),
                ),
                _NavTile(
                  title: 'Patient Analytics',
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  selected: selected == AppSection.patientAnalytics,
                  onTap: () => onSelect(AppSection.patientAnalytics),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 24, endIndent: 24),
          _NavTile(
            title: 'Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            selected: false,
            onTap: () {},
          ),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            leading: Icon(Icons.logout,
                size: 24.r, color: AppConstants.textSecondary),
            title: Text(
              'Logout',
              style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp),
            ),
            onTap: onLogout,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: selected
            ? const LinearGradient(
                colors: [AppConstants.primary, Color(0xFF0052CC)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppConstants.primary.withValues(alpha: 0.3),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12.r),
        child: ListTile(
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(
            selected ? selectedIcon : icon,
            size: 20.r,
            color: selected ? Colors.white : AppConstants.textSecondary,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : AppConstants.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
