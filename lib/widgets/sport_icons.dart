import 'package:flutter/material.dart';

/// Centralized sport and position icon mappings.
/// Uses Material Icons that best represent each sport/position.
class SportIcons {
  SportIcons._();

  static const Map<String, IconData> _sportMap = {
    'Football': Icons.sports_soccer,
    'Basketball': Icons.sports_basketball,
    'Cricket': Icons.sports_cricket,
    'Volleyball': Icons.sports_volleyball,
    'Tennis': Icons.sports_tennis,
    'Badminton': Icons.sports_tennis,
    'Other': Icons.sports,
  };

  static const Map<String, Color> _sportColorMap = {
    'Football': Color(0xFF1B5E20),
    'Basketball': Color(0xFFE65100),
    'Cricket': Color(0xFF0D47A1),
    'Volleyball': Color(0xFF33691E),
    'Tennis': Color(0xFF827717),
    'Badminton': Color(0xFF4A148C),
    'Other': Color(0xFF424242),
  };

  static IconData getSportIcon(String? sport) {
    if (sport == null) return Icons.sports;
    return _sportMap[sport] ?? Icons.sports;
  }

  static Color getSportColor(String? sport) {
    if (sport == null) return const Color(0xFF424242);
    return _sportColorMap[sport] ?? const Color(0xFF424242);
  }

  static Widget sportChip(String? sport, {double size = 16}) {
    if (sport == null || sport.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(getSportIcon(sport), size: size, color: getSportColor(sport)),
        const SizedBox(width: 4),
        Text(sport, style: TextStyle(fontSize: size * 0.85, color: getSportColor(sport), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Position icons mapped to semantic meanings per sport.
class PositionIcons {
  PositionIcons._();

  static const Map<String, IconData> _positionMap = {
    // Football
    'Goalkeeper': Icons.sports_mma,
    'Defender': Icons.shield,
    'Midfielder': Icons.autorenew,
    'Winger': Icons.speed,
    'Striker': Icons.gps_fixed,
    // Basketball
    'Point Guard': Icons.sports_basketball,
    'Shooting Guard': Icons.center_focus_strong,
    'Small Forward': Icons.swap_horiz,
    'Power Forward': Icons.fitness_center,
    'Center': Icons.account_balance,
    // Cricket
    'Batsman': Icons.sports_cricket,
    'Bowler': Icons.sports_baseball,
    'All-Rounder': Icons.change_circle,
    'Wicketkeeper': Icons.pan_tool,
    // Volleyball
    'Setter': Icons.settings,
    'Libero': Icons.shield,
    'Outside Hitter': Icons.wifi_tethering,
    'Opposite Hitter': Icons.swap_vert,
    'Middle Blocker': Icons.block,
    // Tennis / Badminton
    'Singles': Icons.person,
    'Doubles': Icons.people,
    'Mixed Doubles': Icons.group,
    // Generic
    'Any': Icons.sports,
  };

  static const Map<String, Color> _positionColorMap = {
    'Goalkeeper': Color(0xFFFFA000),
    'Defender': Color(0xFF1565C0),
    'Midfielder': Color(0xFF2E7D32),
    'Winger': Color(0xFF6A1B9A),
    'Striker': Color(0xFFC62828),
    'Batsman': Color(0xFF0D47A1),
    'Bowler': Color(0xFFB71C1C),
    'All-Rounder': Color(0xFF1B5E20),
    'Wicketkeeper': Color(0xFFE65100),
    'Any': Color(0xFF424242),
  };

  static IconData getPositionIcon(String? position) {
    if (position == null) return Icons.person;
    return _positionMap[position] ?? Icons.person;
  }

  static Color getPositionColor(String? position) {
    if (position == null) return const Color(0xFF424242);
    return _positionColorMap[position] ?? const Color(0xFF424242);
  }

  static Widget positionChip(String? position, {double size = 16}) {
    if (position == null || position.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(getPositionIcon(position), size: size, color: getPositionColor(position)),
        const SizedBox(width: 4),
        Text(position, style: TextStyle(fontSize: size * 0.85, color: getPositionColor(position), fontWeight: FontWeight.w600)),
      ],
    );
  }
}
