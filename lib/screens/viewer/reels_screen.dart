import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:scoutx/design_system.dart';
import '../../models/clip.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart'
    show DSColors, DSSpacing, DSIconSize, DSRadius, DSMotion, DSElevation, DSCard, EmptyState, DSButton, DSButtonVariant, SectionHeader, AnimatedPage, BrandLogo;
import '../shared/player_profile_view_screen.dart';
import '../shared/reels_feed.dart';
import '../messaging/inbox_screen.dart';

/// Viewer tab: plain reels feed for fun.
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(markSize: 28, fontSize: 20),
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(DSIcons.chatCircleDots, size: DSIconSize.appBar),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InboxScreen()),
              );
            },
          ),
        ],
      ),
      body: uid == null
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnim.value,
                  child: Transform.translate(
                    offset: _slideAnim.value * 30,
                    child: child,
                  ),
                );
              },
              child: ReelsFeed(
                clipsStream: context.read<Database>().streamClips(),
                onOpenProfile: (Clip clip) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PlayerProfileViewScreen(playerId: clip.playerId),
                    ),
                  );
                },
              ),
            ),
    );
  }
}


