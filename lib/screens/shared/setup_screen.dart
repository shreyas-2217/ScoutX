import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:scoutx/design_system.dart';

/// Shown when Firebase hasn't been configured yet (flutterfire configure
/// hasn't been run). Gives clear instructions instead of a crash.
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(DSSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DSColors.onSurface.withValues(alpha: 0.08), DSColors.surfaceContainer],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    DSIcons.cloudSlash,
                    size: DSIconSize.xxl,
                    color: DSColors.onSurface,
                  ),
                ),
                SizedBox(height: DSSpacing.lg),
                Text(
                  'Firebase not configured yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DSSpacing.md),
                Text(
                  'One quick step to connect your app:\n\n'
                  '1. Open a terminal in this project folder\n'
                  '2. Run:   flutterfire configure\n'
                  '3. Log in with your Google account and pick a project\n\n'
                  'This generates lib/firebase_options.dart and the app '
                  'will start working. The step is free.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DSColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: DSSpacing.xl),
                Container(
                  padding: EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    color: DSColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(color: DSColors.outlineVariant),
                  ),
                  child: SelectableText(
                    'flutterfire configure',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      color: DSColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


