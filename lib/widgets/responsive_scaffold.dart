import 'package:flutter/material.dart';
import '../core/app_section.dart';
import '../core/responsive.dart';
import 'app_sidebar.dart';

class ResponsiveScaffold extends StatelessWidget {
  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback onLogout;
  final Widget child;

  const ResponsiveScaffold({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = Responsive.isDesktop(constraints.maxWidth);
        final drawer = Drawer(
          child: AppSidebar(
            selected: selected,
            onSelect: (section) {
              Navigator.of(context).pop();
              onSelect(section);
            },
            onLogout: onLogout,
          ),
        );

        return Scaffold(
          drawer: isDesktop ? null : drawer,
          body: Row(
            children: [
              if (isDesktop)
                AppSidebar(selected: selected, onSelect: onSelect, onLogout: onLogout),
              Expanded(
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }
}
