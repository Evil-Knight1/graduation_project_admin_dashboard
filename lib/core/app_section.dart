enum AppSection { dashboard, doctors, bookings }

extension AppSectionX on AppSection {
  String get title {
    switch (this) {
      case AppSection.dashboard:
        return 'Dashboard';
      case AppSection.doctors:
        return 'Doctors';
      case AppSection.bookings:
        return 'Bookings';
    }
  }
}
