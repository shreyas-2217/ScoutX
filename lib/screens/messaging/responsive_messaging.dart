import 'package:flutter/material.dart';
import 'inbox_screen.dart';
import 'messaging_desktop_screen.dart';

class ResponsiveMessaging extends StatelessWidget {
  const ResponsiveMessaging({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return const MessagingDesktopScreen();
        }
        return const InboxScreen();
      },
    );
  }
}