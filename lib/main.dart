import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/ui/login_page.dart';
import 'features/bookings/bloc/appointments_bloc.dart';
import 'features/bookings/data/appointments_repository.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/doctors/bloc/doctors_bloc.dart';
import 'features/doctors/data/doctors_repository.dart';
import 'features/patients/bloc/patients_bloc.dart';
import 'features/patients/data/patients_repository.dart';
import 'features/home/ui/home_page.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const secureStorage = FlutterSecureStorage();
  final storageService = SecureStorageService(secureStorage);
  final apiService = ApiService(storage: storageService);

  runApp(AdminDashboardApp(
    apiService: apiService,
    storageService: storageService,
  ));
}

class AdminDashboardApp extends StatelessWidget {
  final ApiService apiService;
  final SecureStorageService storageService;

  const AdminDashboardApp({
    super.key,
    required this.apiService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository(apiService)),
        RepositoryProvider(create: (_) => DashboardRepository(apiService)),
        RepositoryProvider(create: (_) => DoctorsRepository(apiService)),
        RepositoryProvider(create: (_) => PatientsRepository(apiService)),
        RepositoryProvider(create: (_) => AppointmentsRepository(apiService)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              repository: context.read<AuthRepository>(),
              storage: storageService,
            )..add(const AppStarted()),
          ),
          BlocProvider(
            create: (context) =>
                DashboardBloc(context.read<DashboardRepository>()),
          ),
          BlocProvider(
            create: (context) => DoctorsBloc(context.read<DoctorsRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                PatientsBloc(context.read<PatientsRepository>()),
          ),
          BlocProvider(
            create: (context) => AppointmentsBloc(
              context.read<AppointmentsRepository>(),
            ),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(1440, 900),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(),
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    return const HomePage();
                  }
                  // Don't show a separated loading screen during login
                  // Only show full-screen spinner during initial app state check
                  if (state.status == AuthStatus.unknown) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const LoginPage();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

