import 'package:flutter/material.dart';

class ResponsiveHelper {
  // ===== Breakpoints =====
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900; // كان 1024 - صغرها شوية
  static const double desktopBreakpoint = 1280; // كان 1440 - صغرها شوية

  // ===== Device Type Checks =====
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  // ===== Get Screen Width =====
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // ===== Responsive Value =====
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  // ===== Responsive Padding =====
  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context: context,
        mobile: 16.0,
        tablet: 32.0,
        desktop: 64.0,
      ),
      vertical: value(
        context: context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }

  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.all(
      value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0),
    );
  }

  // ===== Responsive Font Size =====
  static double fontSize(BuildContext context, double baseSize) {
    return value(
      context: context,
      mobile: baseSize * 0.85,
      tablet: baseSize * 0.95,
      desktop: baseSize,
    );
  }

  // Font Sizes Presets
  static double heading1(BuildContext context) => fontSize(context, 32);
  static double heading2(BuildContext context) => fontSize(context, 24);
  static double heading3(BuildContext context) => fontSize(context, 20);
  static double bodyLarge(BuildContext context) => fontSize(context, 16);
  static double bodyMedium(BuildContext context) => fontSize(context, 14);
  static double bodySmall(BuildContext context) => fontSize(context, 12);

  // ===== Responsive Spacing =====
  static double spacing(BuildContext context, double baseSpacing) {
    return value(
      context: context,
      mobile: baseSpacing * 0.75,
      tablet: baseSpacing * 0.9,
      desktop: baseSpacing,
    );
  }

  // ===== Icon Size =====
  static double iconSize(BuildContext context, double baseSize) {
    return value(
      context: context,
      mobile: baseSize * 0.85,
      tablet: baseSize * 0.95,
      desktop: baseSize,
    );
  }

  // ===== Container Width =====
  static double maxContentWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1100,
    );
  }

  // ===== Card Width =====
  static double cardWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 400,
      desktop: 420,
    );
  }

  // ===== Grid Columns =====
  static int gridColumns(BuildContext context) {
    return value(context: context, mobile: 1, tablet: 2, desktop: 3);
  }

  // ===== Sidebar Width =====
  static double sidebarWidth(BuildContext context) {
    return value(context: context, mobile: 0, tablet: 240, desktop: 280);
  }

  // ===== App Bar Height =====
  static double appBarHeight(BuildContext context) {
    return value(context: context, mobile: 56, tablet: 64, desktop: 72);
  }

  // ===== Border Radius =====
  static double borderRadius(BuildContext context, double baseRadius) {
    return value(
      context: context,
      mobile: baseRadius * 0.8,
      tablet: baseRadius * 0.9,
      desktop: baseRadius,
    );
  }
}

// ===== Responsive Layout Widget =====
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context)) {
          return desktop ?? tablet ?? mobile;
        } else if (ResponsiveHelper.isTablet(context)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// ===== Responsive Builder (Alternative) =====
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}

// ===== Responsive Grid =====
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.gridColumns(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
