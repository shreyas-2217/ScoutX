import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DSColors {
  DSColors._();

  // Brand primary - Puma palette (near-black)
  static const Color volt = Color(0xFF000000);
  static const Color voltDark = Color(0xFF000000);
  static const Color voltLight = Color(0xFF313030);
  static const Color voltSurface = Color(0xFFF1EDEC);

  static const Color cyan = Color(0xFF5F5E5E);
  static const Color green = Color(0xFF5F5E5E);
  static const Color red = Color(0xFFBA1A1A);
  static const Color amber = Color(0xFFFF8F00);
  static const Color indigo = Color(0xFF5F5E5E);

  // Neutrals (light theme - exact from Stitch)
  static const Color surface = Color(0xFFfdf8f8);
  static const Color surfaceContainer = Color(0xFFF1EDEC);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E6);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFfdf8f8);
  static const Color bgElevated = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color onSurfaceVariant = Color(0xFF444748);
  static const Color onSurfaceDisabled = Color(0xFFC4C7C7);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onBg = Color(0xFF1C1B1B);

  static const Color outline = Color(0xFF747878);
  static const Color outlineVariant = Color(0xFFC4C7C7);
  static const Color inverseSurface = Color(0xFF313030);
  static const Color inversePrimary = Color(0xFFC8C6C5);
  static const Color hairline = Color(0xFFE5E2E1);

  // Interaction overlays
  static const Color pressOverlay = Color(0x1A000000);
  static const Color hoverOverlay = Color(0x0D000000);
  static const Color focusOverlay = Color(0x14000000);

  // No gradients in Puma style - flat and minimal

  // Dark theme colors (for dark mode support)
  static const Color darkBg = Color(0xFF1C1B1B);
  static const Color darkSurface = Color(0xFF1C1B1B);
  static const Color darkSurfaceContainer = Color(0xFF2A2929);
  static const Color darkSurfaceContainerHigh = Color(0xFF353434);
  static const Color darkSurfaceContainerHighest = Color(0xFF403F3F);
  static const Color darkSurfaceElevated = Color(0xFF2A2929);

  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOnSurfaceDisabled = Color(0xFF605D62);

  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);
  static const Color darkHairline = Color(0xFF353434);
}

class DSIcons {
  DSIcons._();

  // Brand / identity
  static const IconData brand = Icons.auto_awesome;
  static const IconData x = Icons.close;
  static const IconData profile = Icons.account_circle;

  // Navigation
  static const IconData house = Icons.home_outlined;
  static const IconData houseActive = Icons.home;
  static const IconData compass = Icons.explore_outlined;
  static const IconData compassActive = Icons.explore;
  static const IconData megaphone = Icons.campaign_outlined;
  static const IconData megaphoneActive = Icons.campaign;
  static const IconData trophy = Icons.emoji_events_outlined;
  static const IconData trophyActive = Icons.emoji_events;
  static const IconData user = Icons.person_outline;
  static const IconData userActive = Icons.person;
  static const IconData play = Icons.play_arrow;

  // Media controls
  static const IconData playCircle = Icons.play_circle_outline;
  static const IconData pauseCircle = Icons.pause_circle_outline;
  static const IconData videoCamera = Icons.videocam_outlined;
  static const IconData videoCameraSlash = Icons.videocam_off_outlined;
  static const IconData cloudArrowUp = Icons.cloud_upload_outlined;
  static const IconData cloudSlash = Icons.cloud_off_outlined;

  // User / auth
  static const IconData userPlus = Icons.person_add_outlined;
  static const IconData userSlash = Icons.person_off_outlined;
  static const IconData users = Icons.group_outlined;
  static const IconData lock = Icons.lock_outline;
  static const IconData eye = Icons.visibility_outlined;
  static const IconData eyeSlash = Icons.visibility_off_outlined;
  static const IconData envelope = Icons.email_outlined;
  static const IconData phone = Icons.phone_outlined;

  // Social / engagement
  static const IconData like = Icons.favorite;
  static const IconData likeOutline = Icons.favorite_border;
  static const IconData comment = Icons.chat_bubble_outline;
  static const IconData save = Icons.bookmark;
  static const IconData saveOutline = Icons.bookmark_border;
  static const IconData share = Icons.share_outlined;
  static const IconData link = Icons.link;
  static const IconData copyLink = Icons.copy;
  static const IconData report = Icons.flag_outlined;
  static const IconData hide = Icons.hide_source;
  static const IconData delete = Icons.delete_outline;
  static const IconData trash = Icons.delete_outline;
  static const IconData music = Icons.music_note;
  static const IconData chatCircle = Icons.chat_bubble;
  static const IconData chatCircleDots = Icons.chat_bubble_outline;
  static const IconData forumRounded = Icons.forum_rounded;

  // Actions
  static const IconData send = Icons.send_outlined;
  static const IconData signOut = Icons.logout;
  static const IconData download = Icons.download_outlined;

  // Status / feedback
  static const IconData check = Icons.check;
  static const IconData checkCircle = Icons.check_circle_outline;
  static const IconData xCircle = Icons.cancel_outlined;
  static const IconData hourglass = Icons.hourglass_empty;
  static const IconData warningCircle = Icons.warning_amber;
  static const IconData sealCheck = Icons.verified;

  // Navigation controls
  static const IconData arrowLeft = Icons.arrow_back_ios_new;
  static const IconData arrowForwardRounded = Icons.arrow_forward_rounded;
  static const IconData arrowCounterClockwise = Icons.undo;
  static const IconData arrowsClockwise = Icons.sync;
  static const IconData arrowsVertical = Icons.swipe_vertical;
  static const IconData caretRight = Icons.chevron_right;

  // Input / form
  static const IconData magnifyingGlass = Icons.search;
  static const IconData clearRounded = Icons.clear_rounded;
  static const IconData searchOffRounded = Icons.search_off_rounded;
  static const IconData flashOnRounded = Icons.flash_on;
  static const IconData loginRounded = Icons.login_rounded;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData calendarCheck = Icons.calendar_today_outlined;
  static const IconData mapPin = Icons.location_pin;
  static const IconData textT = Icons.text_fields;
  static const IconData trendUp = Icons.trending_up;
  static const IconData addCircleRounded = Icons.add_circle_outline;
  static const IconData addRounded = Icons.add_rounded;
  static const IconData sportsRounded = Icons.sports_soccer;
  static const IconData shield = Icons.shield_outlined;
  static const IconData smartDisplayRounded = Icons.smart_display_outlined;
  static const IconData radioButtonCheckedRounded = Icons.radio_button_checked;
  static const IconData radioButtonUncheckedRounded = Icons.radio_button_unchecked;

  // UI elements
  static const IconData bookmark = Icons.bookmark;
  static const IconData bookmarkRounded = Icons.bookmark_rounded;
  static const IconData more = Icons.more_horiz;
  static const IconData moreVertRounded = Icons.more_vert;
  static const IconData notebook = Icons.note;
  static const IconData pencil = Icons.edit_outlined;
  static const IconData scale = Icons.scale;
  static const IconData floppyDisk = Icons.save;
  static const IconData circleMinus = Icons.remove_circle_outline;
  static const IconData tooltip = Icons.info_outline;
  static const IconData arrowForward = Icons.arrow_forward;

  // Misc
  static const IconData bell = Icons.notifications_outlined;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData help = Icons.help_outline;
  static const IconData info = Icons.info_outline;
  static const IconData close = Icons.close;
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData expandMore = Icons.expand_more;
  static const IconData expandLess = Icons.expand_less;
  static const IconData keyboardArrowDown = Icons.keyboard_arrow_down;
  static const IconData keyboardArrowUp = Icons.keyboard_arrow_up;
}

class DSSpacing {
  DSSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class DSMotion {
  DSMotion._();

  static const Duration fastest = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration slowest = Duration(milliseconds: 800);
  static const Duration press = Duration(milliseconds: 120);
  static const Duration shimmer = Duration(milliseconds: 2000);
  static const Duration listItemStagger = Duration(milliseconds: 80);
  static const Duration pageTransition = Duration(milliseconds: 320);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve standard = Curves.linear;
}

class DSRadius {
  DSRadius._();

  // Puma style: 4px default, 8px lg, 12px xl
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 1000.0;
  static const double card = 4.0;
  static const double sheet = 8.0;
  static const double dialog = 8.0;
  static const double input = 4.0;
  static const double button = 4.0;
  static const double chip = 4.0;
}

class DSIconSize {
  DSIconSize._();

  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double appBar = 24.0;
  static const double bottomNav = 24.0;
  static const double emptyState = 48.0;
}

class DSElevation {
  DSElevation._();

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> brandGlow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

class DSTypography {
  DSTypography._();

  static TextTheme get light {
    // Use Barlow Condensed for headings, Inter for body
    final headingStyle = GoogleFonts.barlowCondensed();
    final bodyStyle = GoogleFonts.inter();

    return TextTheme(
      displayLarge: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.0,
      ),
      displayMedium: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.0,
      ),
      displaySmall: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.1,
      ),
      headlineLarge: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.1,
      ),
      headlineMedium: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.2,
      ),
      headlineSmall: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.2,
      ),
      titleLarge: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: bodyStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: bodyStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: bodyStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: bodyStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: bodyStyle.copyWith(
        color: DSColors.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: headingStyle.copyWith(
        color: DSColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.0,
      ),
      labelMedium: bodyStyle.copyWith(
        color: DSColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.0,
      ),
      labelSmall: bodyStyle.copyWith(
        color: DSColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.0,
      ),
    );
  }

  static TextTheme get dark {
    final headingStyle = GoogleFonts.barlowCondensed();
    final bodyStyle = GoogleFonts.inter();

    return TextTheme(
      displayLarge: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.0,
      ),
      displayMedium: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.0,
      ),
      displaySmall: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.1,
      ),
      headlineLarge: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.1,
      ),
      headlineMedium: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.2,
      ),
      headlineSmall: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.2,
      ),
      titleLarge: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: bodyStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: bodyStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: bodyStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: bodyStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: bodyStyle.copyWith(
        color: DSColors.darkOnSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: headingStyle.copyWith(
        color: DSColors.darkOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
        height: 1.0,
      ),
      labelMedium: bodyStyle.copyWith(
        color: DSColors.darkOnSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.0,
      ),
      labelSmall: bodyStyle.copyWith(
        color: DSColors.darkOnSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.0,
      ),
    );
  }
}

@immutable
class DSColorScheme extends ThemeExtension<DSColorScheme> {
  final Color brand;
  final Color accent;

  const DSColorScheme({
    required this.brand,
    required this.accent,
  });

  static final DSColorScheme light = DSColorScheme(
    brand: DSColors.volt,
    accent: DSColors.cyan,
  );

  @override
  DSColorScheme copyWith({Color? brand, Color? accent}) {
    return DSColorScheme(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<DSColorScheme> lerp(
    ThemeExtension<DSColorScheme>? other,
    double t,
  ) {
    if (other is! DSColorScheme) return this;
    return DSColorScheme(
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}
