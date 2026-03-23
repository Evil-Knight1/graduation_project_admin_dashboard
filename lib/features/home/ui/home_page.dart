import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_section.dart';
import '../../../widgets/responsive_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../bookings/ui/bookings_page.dart';
import '../../dashboard/ui/dashboard_page.dart';
import '../../doctors/ui/doctors_page.dart';

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
    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE7EDF5))),
        ),
        child: Row(
          children: [
            if (Scaffold.maybeOf(context)?.hasDrawer ?? false)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

