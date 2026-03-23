import 'package:flutter/material.dart';
import '../core/app_section.dart';
import '../core/constants.dart';

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
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE7EDF5))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConstants.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital, color: AppConstants.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Doctor Admin',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          _NavTile(
            title: 'Dashboard',
            icon: Icons.grid_view_rounded,
            selected: selected == AppSection.dashboard,
            onTap: () => onSelect(AppSection.dashboard),
          ),
          _NavTile(
            title: 'Doctors',
            icon: Icons.person_rounded,
            selected: selected == AppSection.doctors,
            onTap: () => onSelect(AppSection.doctors),
          ),
          _NavTile(
            title: 'Bookings',
            icon: Icons.calendar_today_rounded,
            selected: selected == AppSection.bookings,
            onTap: () => onSelect(AppSection.bookings),
          ),
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppConstants.textSecondary),
            title: const Text('Logout'),
            onTap: onLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppConstants.primary : AppConstants.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppConstants.primary : AppConstants.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedTileColor: AppConstants.primary.withOpacity(0.08),
      onTap: onTap,
    );
  }
}
