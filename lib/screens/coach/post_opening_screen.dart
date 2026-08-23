import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/opening.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../shared/widgets.dart';

class PostOpeningScreen extends StatefulWidget {
  const PostOpeningScreen({super.key});

  @override
  State<PostOpeningScreen> createState() => _PostOpeningScreenState();
}

class _PostOpeningScreenState extends State<PostOpeningScreen>
    with SingleTickerProviderStateMixin {
  final _description = TextEditingController();
  String? _sport;
  String? _position;
  String? _skillLevel;
  bool _loading = false;

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
    _description.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final user = auth.user;
    final profile = auth.profile;
    if (user == null || profile == null) return;
    if (_sport == null || _position == null || _skillLevel == null) {
      _snack('Select sport, position and skill level.');
      return;
    }
    setState(() => _loading = true);
    try {
      final opening = Opening(
        id: '',
        coachId: user.uid,
        coachName: profile.displayName,
        teamName: profile.teamName ?? 'My team',
        sport: _sport!,
        position: _position!,
        skillLevel: _skillLevel!,
        description: _description.text.trim(),
        createdAt: DateTime.now(),
      );
      await db.addOpening(opening);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _snack('Failed to post: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Team Opening')),
      body: AnimatedBuilder(
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
        child: AnimatedPage(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DSCard(
                  padding: EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(text: 'What You Need'),
                      SizedBox(height: DSSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _sport,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Sport',
                          prefixIcon: Icon(DSIcons.trophy),
                        ),
                        items: AppConstants.sportList
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _sport = v;
                          _position = null;
                        }),
                      ),
                      if (_sport != null) ...[
                        SizedBox(height: DSSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _position,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Position needed',
                            prefixIcon: Icon(DSIcons.sportsRounded),
                          ),
                          items: (AppConstants.positionsBySport[_sport] ?? const [])
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) => setState(() => _position = v),
                        ),
                      ],
                      SizedBox(height: DSSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _skillLevel,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Skill level',
                          prefixIcon: Icon(DSIcons.trendUp),
                        ),
                        items: AppConstants.skillLevels
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _skillLevel = v),
                      ),
                      SizedBox(height: DSSpacing.lg),
                      SectionHeader(text: 'Description'),
                      SizedBox(height: DSSpacing.md),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'What are you looking for?',
                          hintText: 'e.g. Left-footed winger, good pace, age 18-21…',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: DSSpacing.xl),
                DSButton(
                  label: _loading ? 'Posting…' : 'Post Opening',
                  leadingIcon: DSIcons.megaphone,
                  loading: _loading,
                  fullWidth: true,
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


