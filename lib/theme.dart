import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_system.dart';

class SmoothScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: DSColors.volt,
      onPrimary: DSColors.onBrand,
      primaryContainer: Color(0xFFF1EDEC),
      onPrimaryContainer: Color(0xFF1C1B1B),
      secondary: DSColors.cyan,
      onSecondary: DSColors.onSecondary,
      secondaryContainer: Color(0xFFE1DFDF),
      onSecondaryContainer: Color(0xFF626262),
      tertiary: Color(0xFF1C1B1A),
      onTertiary: DSColors.onTertiary,
      tertiaryContainer: Color(0xFF1C1B1A),
      onTertiaryContainer: Color(0xFF858383),
      error: DSColors.red,
      onError: DSColors.onError,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: DSColors.surface,
      onSurface: DSColors.onSurface,
      onSurfaceVariant: DSColors.onSurfaceVariant,
      surfaceContainer: DSColors.surfaceContainer,
      surfaceContainerHigh: DSColors.surfaceContainerHigh,
      surfaceContainerHighest: DSColors.surfaceContainerHighest,
      surfaceContainerLow: Color(0xFFF7F3F2),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceTint: Color(0xFF5F5E5E),
      outline: DSColors.outline,
      outlineVariant: DSColors.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: DSColors.inverseSurface,
      onInverseSurface: Color(0xFFF4F0EF),
      inversePrimary: DSColors.inversePrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    final textTheme = DSTypography.light;

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: DSColors.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: DSColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: DSColors.onSurface,
        ),
        iconTheme: IconThemeData(
          color: DSColors.onSurface,
          size: DSIconSize.appBar,
        ),
        actionsIconTheme: IconThemeData(
          color: DSColors.onSurfaceVariant,
          size: DSIconSize.appBar,
        ),
        toolbarHeight: 56,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DSColors.onSurface,
        selectionColor: DSColors.onSurface.withValues(alpha: 0.20),
        selectionHandleColor: DSColors.onSurface,
      ),

      cardTheme: CardThemeData(
        color: DSColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.card),
          side: BorderSide(
            color: DSColors.outlineVariant,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DSColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DSColors.onSurface.withValues(alpha: 0.08),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: DSColors.onSurface,
              size: DSIconSize.bottomNav,
            );
          }
          return IconThemeData(
            color: DSColors.onSurfaceVariant,
            size: DSIconSize.bottomNav,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final base = textTheme.labelSmall ?? textTheme.bodyMedium!;
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: DSColors.onSurface,
              fontWeight: FontWeight.w700,
            );
          }
          return base.copyWith(
            color: DSColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DSRadius.sheet),
          ),
        ),
        modalBarrierColor: Colors.black.withValues(alpha: 0.4),
        dragHandleColor: DSColors.surfaceContainerHighest,
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: DSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.dialog),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium,
        alignment: Alignment.center,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DSColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: DSColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: DSColors.onSurface,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: DSColors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: DSColors.red,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide(
            color: DSColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: DSColors.onSurface,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: DSColors.red,
        ),
        prefixIconColor: DSColors.onSurfaceVariant,
        suffixIconColor: DSColors.onSurfaceVariant,
        iconColor: DSColors.onSurfaceVariant,
        counterStyle: textTheme.bodySmall?.copyWith(
          color: DSColors.onSurfaceDisabled,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return DSColors.onSurface.withValues(alpha: 0.4);
            }
            return DSColors.onSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return DSColors.surface.withValues(alpha: 0.7);
            }
            return DSColors.surface;
          }),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(0, 52)),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSRadius.button),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(
            textTheme.labelLarge?.copyWith(
              letterSpacing: 0.32,
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
          shadowColor: WidgetStateProperty.all<Color?>(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return DSColors.pressOverlay;
            }
            if (states.contains(WidgetState.hovered)) {
              return DSColors.hoverOverlay;
            }
            if (states.contains(WidgetState.focused)) {
              return DSColors.focusOverlay;
            }
            return Colors.transparent;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(DSColors.onSurface),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(0, 52)),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSRadius.button),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.32),
          ),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(
              color: DSColors.outlineVariant,
              width: 1,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return DSColors.onSurface.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return DSColors.onSurface.withValues(alpha: 0.04);
            }
            if (states.contains(WidgetState.focused)) {
              return DSColors.onSurface.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DSColors.onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.button),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DSColors.onSurface,
        foregroundColor: DSColors.surface,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.button),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        extendedTextStyle: textTheme.labelLarge,
        extendedIconLabelSpacing: DSSpacing.sm,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: DSColors.surfaceContainer,
        disabledColor: DSColors.surfaceContainerHigh,
        selectedColor: DSColors.onSurface.withValues(alpha: 0.12),
        secondarySelectedColor: DSColors.onSurface.withValues(alpha: 0.18),
        checkmarkColor: DSColors.onSurface,
        side: const BorderSide(
          color: DSColors.outlineVariant,
          width: 1,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: DSColors.onSurface,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: DSColors.onSurface,
        ),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.chip),
        ),
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: DSColors.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.surface,
        ),
        actionTextColor: DSColors.surface,
        disabledActionTextColor: DSColors.surface.withValues(alpha: 0.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        elevation: 0,
        actionOverflowThreshold: 0.25,
      ),

      tabBarTheme: TabBarThemeData(
        indicatorColor: DSColors.onSurface,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(width: 3, color: DSColors.onSurface),
        ),
        dividerColor: DSColors.outlineVariant,
        labelColor: DSColors.onSurface,
        unselectedLabelColor: DSColors.onSurfaceVariant,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return DSColors.pressOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return DSColors.hoverOverlay;
          }
          return Colors.transparent;
        }),
      ),

      dividerTheme: DividerThemeData(
        color: DSColors.outlineVariant,
        thickness: 1,
        space: 1,
        indent: 0,
        endIndent: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DSColors.onSurface,
        linearTrackColor: DSColors.surfaceContainerHigh,
        circularTrackColor: DSColors.surfaceContainerHigh,
        refreshBackgroundColor: DSColors.surfaceContainer,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: DSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        textStyle: textTheme.bodyMedium,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.bodyMedium!.copyWith(
              color: DSColors.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.bodyMedium!;
        }),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: DSColors.onSurface.withValues(alpha: 0.08),
        selectedColor: DSColors.onSurface,
        iconColor: DSColors.onSurfaceVariant,
        textColor: DSColors.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: DSColors.onSurface,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.onSurfaceVariant,
        ),
        leadingAndTrailingTextStyle: textTheme.bodyMedium,
        minLeadingWidth: 40,
        horizontalTitleGap: DSSpacing.md,
        minVerticalPadding: DSSpacing.sm,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DSColors.onSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: DSColors.surface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        preferBelow: true,
        verticalOffset: DSSpacing.xs,
        waitDuration: DSMotion.fast,
        showDuration: DSMotion.slow,
      ),

      extensions: <ThemeExtension<dynamic>>[
        DSColorScheme.light,
      ],

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.iOS: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.macOS: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.windows: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.linux: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _FadeScalePageTransitionsBuilder(),
        },
      ),

      splashColor: DSColors.onSurface.withValues(alpha: 0.06),
      highlightColor: DSColors.onSurface.withValues(alpha: 0.03),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: Color(0xFFE6E1E5),
      onPrimary: Color(0xFF1C1B1B),
      primaryContainer: Color(0xFF49454F),
      onPrimaryContainer: Color(0xFFE6E1E5),
      secondary: Color(0xFFCAC4D0),
      onSecondary: Color(0xFF1D1B20),
      secondaryContainer: Color(0xFF49454F),
      onSecondaryContainer: Color(0xFFCAC4D0),
      tertiary: Color(0xFFCAC4D0),
      onTertiary: Color(0xFF1D1B20),
      tertiaryContainer: Color(0xFF49454F),
      onTertiaryContainer: Color(0xFFCAC4D0),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF2B8B5),
      surface: DSColors.darkSurface,
      onSurface: DSColors.darkOnSurface,
      onSurfaceVariant: DSColors.darkOnSurfaceVariant,
      surfaceContainer: DSColors.darkSurfaceContainer,
      surfaceContainerHigh: DSColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: DSColors.darkSurfaceContainerHighest,
      surfaceContainerLow: DSColors.darkSurface,
      surfaceContainerLowest: DSColors.darkBg,
      surfaceTint: Color(0xFFE6E1E5),
      outline: DSColors.darkOutline,
      outlineVariant: DSColors.darkOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: DSColors.darkOnSurface,
      onInverseSurface: DSColors.darkBg,
      inversePrimary: Color(0xFF313030),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    final textTheme = DSTypography.dark;

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: DSColors.darkBg,

      appBarTheme: AppBarTheme(
        backgroundColor: DSColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: DSColors.darkOnSurface,
        ),
        iconTheme: IconThemeData(
          color: DSColors.darkOnSurface,
          size: DSIconSize.appBar,
        ),
        actionsIconTheme: IconThemeData(
          color: DSColors.darkOnSurfaceVariant,
          size: DSIconSize.appBar,
        ),
        toolbarHeight: 56,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xFFE6E1E5),
        selectionColor: const Color(0xFFE6E1E5).withValues(alpha: 0.20),
        selectionHandleColor: const Color(0xFFE6E1E5),
      ),

      cardTheme: CardThemeData(
        color: DSColors.darkSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.card),
          side: const BorderSide(
            color: DSColors.darkOutline,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DSColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE6E1E5).withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color(0xFFE6E1E5),
              size: DSIconSize.bottomNav,
            );
          }
          return IconThemeData(
            color: DSColors.darkOnSurfaceVariant,
            size: DSIconSize.bottomNav,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final base = textTheme.labelSmall ?? textTheme.bodyMedium!;
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: const Color(0xFFE6E1E5),
              fontWeight: FontWeight.w700,
            );
          }
          return base.copyWith(
            color: DSColors.darkOnSurfaceVariant,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DSColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DSRadius.sheet),
          ),
        ),
        modalBarrierColor: Colors.black.withValues(alpha: 0.4),
        dragHandleColor: DSColors.darkSurfaceContainerHighest,
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: DSColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.dialog),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium,
        alignment: Alignment.center,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DSColors.darkSurfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: DSColors.darkOutline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: Color(0xFFE6E1E5),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: Color(0xFFF2B8B5),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: const BorderSide(
            color: Color(0xFFF2B8B5),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide(
            color: DSColors.darkOutline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.darkOnSurfaceDisabled,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.darkOnSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: const Color(0xFFE6E1E5),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: const Color(0xFFF2B8B5),
        ),
        prefixIconColor: DSColors.darkOnSurfaceVariant,
        suffixIconColor: DSColors.darkOnSurfaceVariant,
        iconColor: DSColors.darkOnSurfaceVariant,
        counterStyle: textTheme.bodySmall?.copyWith(
          color: DSColors.darkOnSurfaceDisabled,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.4);
            }
            return const Color(0xFFE6E1E5);
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFF1C1B1B).withValues(alpha: 0.7);
            }
            return const Color(0xFF1C1B1B);
          }),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(0, 52)),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSRadius.button),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.32),
          ),
          elevation: WidgetStateProperty.all<double>(0),
          shadowColor: WidgetStateProperty.all<Color?>(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.12);
            }
            return Colors.transparent;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFFE6E1E5)),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(0, 52)),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSRadius.button),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.32),
          ),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(
              color: DSColors.darkOutline,
              width: 1,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.04);
            }
            if (states.contains(WidgetState.focused)) {
              return const Color(0xFFE6E1E5).withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE6E1E5),
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.button),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFE6E1E5),
        foregroundColor: const Color(0xFF1C1B1B),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.button),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        extendedTextStyle: textTheme.labelLarge,
        extendedIconLabelSpacing: DSSpacing.sm,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: DSColors.darkSurfaceContainer,
        disabledColor: DSColors.darkSurfaceContainerHigh,
        selectedColor: const Color(0xFFE6E1E5).withValues(alpha: 0.12),
        secondarySelectedColor: const Color(0xFFE6E1E5).withValues(alpha: 0.18),
        checkmarkColor: const Color(0xFFE6E1E5),
        side: const BorderSide(
          color: DSColors.darkOutline,
          width: 1,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: DSColors.darkOnSurface,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: const Color(0xFFE6E1E5),
        ),
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.chip),
        ),
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: DSColors.darkSurfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.darkOnSurface,
        ),
        actionTextColor: const Color(0xFFE6E1E5),
        disabledActionTextColor: const Color(0xFFE6E1E5).withValues(alpha: 0.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        elevation: 0,
        actionOverflowThreshold: 0.25,
      ),

      tabBarTheme: TabBarThemeData(
        indicatorColor: const Color(0xFFE6E1E5),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: Color(0xFFE6E1E5)),
        ),
        dividerColor: DSColors.darkOutline,
        labelColor: DSColors.darkOnSurface,
        unselectedLabelColor: DSColors.darkOnSurfaceVariant,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFFE6E1E5).withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFE6E1E5).withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
      ),

      dividerTheme: DividerThemeData(
        color: DSColors.darkOutline,
        thickness: 1,
        space: 1,
        indent: 0,
        endIndent: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(0xFFE6E1E5),
        linearTrackColor: DSColors.darkSurfaceContainerHigh,
        circularTrackColor: DSColors.darkSurfaceContainerHigh,
        refreshBackgroundColor: DSColors.darkSurfaceContainer,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: DSColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        textStyle: textTheme.bodyMedium,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.bodyMedium!.copyWith(
              color: const Color(0xFFE6E1E5),
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.bodyMedium!;
        }),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: const Color(0xFFE6E1E5).withValues(alpha: 0.08),
        selectedColor: const Color(0xFFE6E1E5),
        iconColor: DSColors.darkOnSurfaceVariant,
        textColor: DSColors.darkOnSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: DSColors.darkOnSurface,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: DSColors.darkOnSurfaceVariant,
        ),
        leadingAndTrailingTextStyle: textTheme.bodyMedium,
        minLeadingWidth: 40,
        horizontalTitleGap: DSSpacing.md,
        minVerticalPadding: DSSpacing.sm,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DSColors.darkOnSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: DSColors.darkBg,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        preferBelow: true,
        verticalOffset: DSSpacing.xs,
        waitDuration: DSMotion.fast,
        showDuration: DSMotion.slow,
      ),

      extensions: <ThemeExtension<dynamic>>[
        DSColorScheme(
          brand: const Color(0xFFE6E1E5),
          accent: const Color(0xFFCAC4D0),
        ),
      ],

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.iOS: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.macOS: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.windows: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.linux: _FadeScalePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _FadeScalePageTransitionsBuilder(),
        },
      ),

      splashColor: const Color(0xFFE6E1E5).withValues(alpha: 0.06),
      highlightColor: const Color(0xFFE6E1E5).withValues(alpha: 0.03),
    );
  }
}

class _FadeScalePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeScalePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: DSMotion.easeOut,
      reverseCurve: DSMotion.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: DSMotion.easeOut),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}
