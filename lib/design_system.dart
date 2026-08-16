import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DSColors {
  DSColors._();

  // Brand primary - Green palette
  static const Color volt = Color(0xFF1B6B3A);
  static const Color voltDark = Color(0xFF145A2E);
  static const Color voltLight = Color(0xFF2E8B4F);
  static const Color voltSurface = Color(0xFFE8F5E9);

  static const Color cyan = Color(0xFF43A047);
  static const Color green = Color(0xFF2E7D32);
  static const Color red = Color(0xFFE53935);
  static const Color amber = Color(0xFFFF8F00);
  static const Color indigo = Color(0xFF5C6BC0);

  // Neutrals (light theme)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF5F5F5);
  static const Color surfaceContainerHigh = Color(0xFFEEEEEE);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF8F9FA);
  static const Color bgElevated = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color onSurfaceDisabled = Color(0xFFBDBDBD);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onBg = Color(0xFF1A1A1A);

  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFEEEEEE);
  static const Color inverseSurface = Color(0xFF1A1A1A);
  static const Color inversePrimary = Color(0xFF1B6B3A);
  static const Color hairline = Color(0xFFEEEEEE);

  // Interaction overlays
  static const Color pressOverlay = Color(0x1A1B6B3A);
  static const Color hoverOverlay = Color(0x0D1B6B3A);
  static const Color focusOverlay = Color(0x141B6B3A);

  // Gradients
  static const Gradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B6B3A),
      Color(0xFF2E8B4F),
    ],
  );

  static const Gradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7D32),
      Color(0xFF43A047),
    ],
  );

  static const Gradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFF0F0F0),
    ],
  );

  static const Gradient brandSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A1B6B3A),
      Color(0x0D2E8B4F),
    ],
  );

  static const Gradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8F9FA),
    ],
  );

  // Dark theme colors
  static const Color darkBg = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A1F25);
  static const Color darkSurfaceContainer = Color(0xFF232A31);
  static const Color darkSurfaceContainerHigh = Color(0xFF2C343C);
  static const Color darkSurfaceContainerHighest = Color(0xFF374049);
  static const Color darkSurfaceElevated = Color(0xFF1E252B);

  static const Color darkOnSurface = Color(0xFFF0F2F5);
  static const Color darkOnSurfaceVariant = Color(0xFF8B95A0);
  static const Color darkOnSurfaceDisabled = Color(0xFF4A5568);

  static const Color darkOutline = Color(0xFF2C343C);
  static const Color darkOutlineVariant = Color(0xFF232A31);
  static const Color darkHairline = Color(0xFF232A31);
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
  static const IconData forum_rounded = Icons.forum_rounded;

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
  static const IconData arrow_forward_rounded = Icons.arrow_forward_rounded;
  static const IconData arrowCounterClockwise = Icons.undo;
  static const IconData arrowsClockwise = Icons.sync;
  static const IconData arrowsVertical = Icons.swipe_vertical;
  static const IconData caretRight = Icons.chevron_right;

  // Input / form
  static const IconData magnifyingGlass = Icons.search;
  static const IconData clear_rounded = Icons.clear_rounded;
  static const IconData search_off_rounded = Icons.search_off_rounded;
  static const IconData flash_on_rounded = Icons.flash_on;
  static const IconData login_rounded = Icons.login_rounded;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData calendarCheck = Icons.calendar_today_outlined;
  static const IconData mapPin = Icons.location_pin;
  static const IconData textT = Icons.text_fields;
  static const IconData trendUp = Icons.trending_up;
  static const IconData add_circle_rounded = Icons.add_circle_outline;
  static const IconData add_rounded = Icons.add_rounded;
  static const IconData sports_rounded = Icons.sports_soccer;
  static const IconData shield = Icons.shield_outlined;
  static const IconData smart_display_rounded = Icons.smart_display_outlined;
  static const IconData radio_button_checked_rounded = Icons.radio_button_checked;
  static const IconData radio_button_unchecked_rounded = Icons.radio_button_unchecked;

  // UI elements
  static const IconData bookmark = Icons.bookmark;
  static const IconData bookmark_rounded = Icons.bookmark_rounded;
  static const IconData more = Icons.more_horiz;
  static const IconData more_vert_rounded = Icons.more_vert;
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

  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 1000.0;
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double dialog = 16.0;
  static const double input = 12.0;
  static const double button = 12.0;
  static const double chip = 999.0;
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
      color: Color(0x261B6B3A),
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
    final base = GoogleFonts.interTextTheme();
    return base.apply(
      bodyColor: DSColors.onSurface,
      displayColor: DSColors.onSurface,
      decorationColor: DSColors.onSurface,
    ).copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: DSColors.onSurface,
        height: 1.6,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: DSColors.onSurface,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: DSColors.onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: DSColors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  static TextTheme get dark {
    final base = GoogleFonts.interTextTheme();
    return base.apply(
      bodyColor: DSColors.darkOnSurface,
      displayColor: DSColors.darkOnSurface,
      decorationColor: DSColors.darkOnSurface,
    ).copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: DSColors.darkOnSurface,
        height: 1.6,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: DSColors.darkOnSurface,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: DSColors.darkOnSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: DSColors.darkOnSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: DSColors.darkOnSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
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
