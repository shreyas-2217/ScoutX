import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();
  
  // Phone
  static const double mobile = 0;
  static const double mobileMax = 600;
  
  // Tablet  
  static const double tablet = 601;
  static const double tabletMax = 1024;
  
  // Desktop
  static const double desktop = 1025;
  static const double desktopMax = 1440;
  
  // Large Desktop
  static const double largeDesktop = 1441;
}

class ResponsiveUtils {
  ResponsiveUtils._();
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= Breakpoints.mobileMax;
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width > Breakpoints.mobileMax && width <= Breakpoints.tabletMax;
  }
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > Breakpoints.tabletMax;
  
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > Breakpoints.largeDesktop;
  
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= Breakpoints.mobileMax) return DeviceType.mobile;
    if (width <= Breakpoints.tabletMax) return DeviceType.tablet;
    if (width <= Breakpoints.desktopMax) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }
  
  // Content max widths
  static double getMaxContentWidth(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 720;
      case DeviceType.desktop:
        return 1100;
      case DeviceType.largeDesktop:
        return 1200;
    }
  }
  
  // Column counts for grids
  static int getGridColumns(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }
  
  // Horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
      case DeviceType.largeDesktop:
        return 32;
    }
  }
}

enum DeviceType { mobile, tablet, desktop, largeDesktop }

// Responsive builder widget
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
        if (constraints.maxWidth <= Breakpoints.mobileMax) {
          return mobile;
        } else if (constraints.maxWidth <= Breakpoints.tabletMax) {
          return tablet ?? mobile;
        } else {
          return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

// Responsive container that centers content with max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final maxW = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    final horizontalPadding = padding ?? 
        EdgeInsets.symmetric(horizontal: ResponsiveUtils.getHorizontalPadding(context));
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: horizontalPadding,
          child: child,
        ),
      ),
    );
  }
}

// Responsive grid
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
    final columns = ResponsiveUtils.getGridColumns(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = (totalWidth - (spacing * (columns - 1))) / columns;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}
