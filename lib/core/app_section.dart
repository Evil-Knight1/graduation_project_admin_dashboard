enum AppSection { dashboard, doctors, patients, patientAnalytics, bookings }

extension AppSectionX on AppSection {
  String get title {
    switch (this) {
      case AppSection.dashboard:
        return 'Dashboard';
      case AppSection.doctors:
        return 'Doctors';
      case AppSection.patients:
        return 'Patients';
      case AppSection.patientAnalytics:
        return 'Patient Analytics';
      case AppSection.bookings:
        return 'Bookings';
    }
  }
}
