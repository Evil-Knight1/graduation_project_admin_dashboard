import 'constants.dart';

class Responsive {
  static bool isDesktop(double width) => width >= AppConstants.desktopMinWidth;
  static bool isTablet(double width) =>
      width >= AppConstants.tabletMinWidth && width < AppConstants.desktopMinWidth;
  static bool isMobile(double width) => width < AppConstants.tabletMinWidth;
}
