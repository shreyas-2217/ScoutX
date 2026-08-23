import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clip.dart' as models;
import '../../services/cloudinary_service.dart';
import '../../services/database.dart';
import '../../services/search_parser.dart';
import '../../services/search_service.dart';
import 'clip_player_screen.dart';
import 'player_profile_view_screen.dart';
import 'widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<SearchResult> _clipResults = [];
  List<UserSearchResult> _userResults = [];
  List<String> _suggestions = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _controller.text;
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      if (text.trim().isEmpty) {
        setState(() {
          _clipResults = [];
          _userResults = [];
          _suggestions = [];
          _hasSearched = false;
        });
        return;
      }
      final parsed = SearchParser.parse(text);
      final suggestions = SearchParser.getSuggestions(text);
      setState(() {
        _suggestions = suggestions;
      });
      _performSearch(parsed);
    });
  }

  void _performSearch(SearchParseResult parsed) async {
    setState(() => _isSearching = true);
    final db = context.read<Database>();

    try {
      final clipsSnap = await db.streamClips(limit: 150).first;
      final usersSnap = await db.searchUsers('').first;

      final clipResults = SearchService.searchClips(clipsSnap, parsed);
      final userResults = SearchService.searchUsers(usersSnap, parsed);

      if (mounted) {
        setState(() {
          _clipResults = clipResults;
          _userResults = userResults;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _submitSearch(String text) {
    if (text.trim().isEmpty) return;
    final parsed = SearchParser.parse(text);
    setState(() {
      _hasSearched = true;
    });
    _performSearch(parsed);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onSubmitted: _submitSearch,
          decoration: InputDecoration(
            hintText: 'Search players, highlights, skills...',
            hintStyle: TextStyle(
              color: DSColors.onSurfaceVariant,
              fontSize: 16,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _clipResults = [];
                  _userResults = [];
                  _suggestions = [];
                  _hasSearched = false;
                });
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasSearched) {
      return _buildResults();
    }
    if (_suggestions.isNotEmpty) {
      return _buildSuggestions();
    }
    return _buildEmpty();
  }

  Widget _buildEmpty() {
    return ListView(
      padding: EdgeInsets.all(DSSpacing.lg),
      children: [
        Text(
          'Popular searches',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DSColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PresetChip(
              label: 'Football highlights',
              onTap: () {
                _controller.text = 'Football highlights';
                _submitSearch('Football highlights');
              },
            ),
            _PresetChip(
              label: 'Bangalore football',
              onTap: () {
                _controller.text = 'Bangalore football';
                _submitSearch('Bangalore football');
              },
            ),
            _PresetChip(
              label: 'U18 winger',
              onTap: () {
                _controller.text = 'U18 winger';
                _submitSearch('U18 winger');
              },
            ),
            _PresetChip(
              label: 'Cricket bowling',
              onTap: () {
                _controller.text = 'Cricket bowling';
                _submitSearch('Cricket bowling');
              },
            ),
            _PresetChip(
              label: 'Football dribbling',
              onTap: () {
                _controller.text = 'Football dribbling';
                _submitSearch('Football dribbling');
              },
            ),
            _PresetChip(
              label: 'Basketball training',
              onTap: () {
                _controller.text = 'Basketball training';
                _submitSearch('Basketball training');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: DSSpacing.xs),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final s = _suggestions[index];
        return ListTile(
          leading: Icon(Icons.search, size: 20, color: DSColors.onSurfaceVariant),
          title: Text(s),
          dense: true,
          onTap: () {
            _controller.text = s;
            _submitSearch(s);
          },
        );
      },
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator(color: DSColors.onSurface));
    }

    final hasClips = _clipResults.isNotEmpty;
    final hasUsers = _userResults.isNotEmpty;

    if (!hasClips && !hasUsers) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try different keywords or remove filters.',
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: DSSpacing.sm),
      children: [
        if (_userResults.isNotEmpty) ...[
          _SectionHeader(label: 'Players', count: _userResults.length),
          ..._userResults.take(5).map((r) => _UserTile(result: r)),
        ],
        if (_clipResults.isNotEmpty) ...[
          _SectionHeader(label: 'Highlights', count: _clipResults.length),
          ..._clipResults.take(10).map((r) => _ClipTile(result: r)),
        ],
        SizedBox(height: DSSpacing.xl),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(DSSpacing.lg, DSSpacing.md, DSSpacing.lg, DSSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DSColors.onSurface,
            ),
          ),
          SizedBox(width: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: DSColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(DSRadius.chip),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 11, color: DSColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserSearchResult result;
  const _UserTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final user = result.user;
    return ListTile(
      leading: InitialsAvatar(name: user.displayName, radius: 20),
      title: Text(
        user.displayName,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          if (user.sport != null) user.sport!,
          if (user.position != null) user.position!,
          if (user.city != null) user.city!,
        ].join(' · '),
        style: TextStyle(fontSize: 12, color: DSColors.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right, color: DSColors.onSurfaceVariant),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerProfileViewScreen(playerId: user.uid),
          ),
        );
      },
    );
  }
}

class _ClipTile extends StatelessWidget {
  final SearchResult result;
  const _ClipTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final clip = result.clip;
    final thumbnail = CloudinaryService.videoThumbnail(
      clip.videoUrl,
      width: 112,
      height: 112,
    );
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadius.card),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSColors.onSurface.withValues(alpha: 0.3),
                      DSColors.cyan.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              if (thumbnail != null)
                Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              const Center(
                child: Icon(Icons.play_arrow_rounded,
                    size: 22, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        clip.title.isNotEmpty ? clip.title : clip.playerName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clip.playerName,
            style: TextStyle(fontSize: 12, color: DSColors.onSurfaceVariant),
          ),
          SizedBox(height: 2),
          _buildMetadataBadges(clip),
          if (result.matchReasons.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              result.matchReasons.take(3).join(' · '),
              style: TextStyle(
                fontSize: 11,
                color: DSColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      isThreeLine: true,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClipPlayerScreen(
              videoUrl: clip.videoUrl,
              title: clip.title,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataBadges(models.Clip clip) {
    final badges = <String>[];
    if (clip.sport.isNotEmpty) badges.add(clip.sport);
    if (clip.position.isNotEmpty) badges.add(clip.position);
    if (clip.location != null) badges.add(clip.location!);
    if (clip.ageGroup != null) badges.add(clip.ageGroup!);

    if (badges.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: badges.take(4).map((b) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: DSColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(DSRadius.chip),
          ),
          child: Text(
            b,
            style: TextStyle(
              fontSize: 10,
              color: DSColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PresetChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 13)),
      avatar: Icon(Icons.search, size: 16),
      onPressed: onTap,
      backgroundColor: DSColors.surfaceContainerHigh,
      side: BorderSide(color: DSColors.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSRadius.chip),
      ),
    );
  }
}
