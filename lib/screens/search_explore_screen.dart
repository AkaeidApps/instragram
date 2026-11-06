import 'package:flutter/material.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../models/user.dart';
import '../services/instagram_service.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';
import 'detail_screen.dart';

class SearchExploreScreen extends StatefulWidget {
  const SearchExploreScreen({super.key});

  @override
  State<SearchExploreScreen> createState() => _SearchExploreScreenState();
}

class _SearchExploreScreenState extends State<SearchExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PopularResult> _allResults = [];
  List<PopularResult> _filteredResults = [];
  bool _isLoading = true;

  static const _creators = [
    ('neymarjr', 'Neymar Jr', true),
    ('vinijr', 'Vini Jr.', true),
    ('leomessi', 'Leo Messi', true),
    ('alhilal', 'Al Hilal', true),
    ('brasil', 'CBF', true),
    ('paulina.perez', 'Paulina Perez', false),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await InstagramService.searchPopular('austin');
      if (!mounted) return;
      setState(() {
        _allResults = response.popularResults.isNotEmpty
            ? response.popularResults
            : _demoResults();
        _filteredResults = _allResults;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allResults = _demoResults();
        _filteredResults = _allResults;
        _isLoading = false;
      });
    }
  }

  List<PopularResult> _demoResults() {
    return List.generate(18, (index) {
      return PopularResult(
        id: 'explore-$index',
        position: index + 1,
        shortcode: 'explore$index',
        link: 'https://www.instagram.com/',
        displayUrl: index.isEven
            ? DemoMedia.soccerPhoto(index)
            : DemoMedia.photo(index),
        caption: index.isEven
            ? DemoMedia.soccerCaptions[index % DemoMedia.soccerCaptions.length]
            : DemoMedia.captions[index % DemoMedia.captions.length],
        user: User(
          id: 'explore-user-$index',
          isVerified: index % 3 == 0,
          profilePicUrl: DemoMedia.avatar(index),
          username: _creators[(index % (_creators.length - 1))].$1,
          link: 'https://www.instagram.com/',
        ),
        playCount: 3200 + index * 1750,
        videoVersions: index % 4 == 0
            ? [DemoMedia.reelVideo(index)]
            : const [],
      );
    });
  }

  String _imageFor(PopularResult result, int index) {
    if (result.displayUrl.contains('cdninstagram')) {
      return index.isEven
          ? DemoMedia.soccerPhoto(index)
          : DemoMedia.photo(index);
    }
    return result.displayUrl.isNotEmpty
        ? result.displayUrl
        : DemoMedia.photoFor(result.id);
  }

  void _onSearchChanged(String query) {
    final value = query.trim().toLowerCase();
    setState(() {
      if (value.isEmpty) {
        _filteredResults = _allResults;
      } else {
        _filteredResults = _allResults.where((result) {
          return result.user.username.toLowerCase().contains(value) ||
              (result.caption?.toLowerCase().contains(value) ?? false);
        }).toList();
      }
    });
  }

  void _selectKeyword(String keyword) {
    _searchController.text = keyword;
    _onSearchChanged(keyword);
    _focusNode.unfocus();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  List<(String, String, bool)> get _matchedCreators {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _creators
        .where(
          (creator) =>
              creator.$1.toLowerCase().contains(query) ||
              creator.$2.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Search by photo',
                    onPressed: _showVisualSearch,
                    icon: const Icon(Icons.center_focus_weak_rounded, size: 24),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search people, places and tags',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.muted,
                    size: 21,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.muted,
                            size: 19,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_searchController.text.isEmpty) _trendingChips(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (_matchedCreators.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                                  child: Text(
                                    'ACCOUNTS',
                                    style: AppTheme.sectionLabel,
                                  ),
                                ),
                                for (final creator in _matchedCreators)
                                  _accountRow(creator),
                                const SizedBox(height: 6),
                                const Divider(),
                              ],
                            ),
                          ),
                        if (_searchController.text.isEmpty) ...[
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                                  child: Text(
                                    'SUGGESTED CREATORS',
                                    style: AppTheme.sectionLabel,
                                  ),
                                ),
                                SizedBox(
                                  height: 116,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: _creators.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) =>
                                        _creator(creator: _creators[index]),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                              ],
                            ),
                          ),
                        ],
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Row(
                              children: [
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'Explore'
                                      : 'Results',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_searchController.text.isNotEmpty)
                                  Text(
                                    '${_filteredResults.length}',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                const Spacer(),
                                const Icon(
                                  Icons.trending_up_rounded,
                                  size: 17,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_filteredResults.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _emptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(2, 0, 2, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 2,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _gridItem(
                                  _filteredResults[index],
                                  index,
                                ),
                                childCount: _filteredResults.length,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trendingChips() {
    const tags = ['#football', '#reels', '#travel', '#austin', '#style'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _selectKeyword(tags[index].substring(1)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              tags[index],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _creator({required (String, String, bool) creator}) {
    return AnimatedBuilder(
      animation: LocalAppState.instance,
      builder: (context, _) {
        final following = LocalAppState.instance.isFollowing(
          'explore-${creator.$1}',
        );
        return SizedBox(
          width: 72,
          child: Column(
            children: [
              InstagramAvatar(
                url: creator.$1 == DemoMedia.profileUsername
                    ? DemoMedia.profileAvatarSmall
                    : DemoMedia.avatarFor(creator.$1, size: 200),
                size: 62,
                isVerified: creator.$3,
                showRing: creator.$1 == DemoMedia.profileUsername,
              ),
              const SizedBox(height: 7),
              Text(
                creator.$1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () => LocalAppState.instance.toggleFollow(
                  'explore-${creator.$1}',
                ),
                child: Text(
                  following ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: following ? AppColors.muted : AppColors.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _accountRow((String, String, bool) creator) {
    final following = LocalAppState.instance.isFollowing(
      'explore-${creator.$1}',
    );
    return AnimatedBuilder(
      animation: LocalAppState.instance,
      builder: (context, _) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: InstagramAvatar(
          url: creator.$1 == DemoMedia.profileUsername
              ? DemoMedia.profileAvatarSmall
              : DemoMedia.avatarFor(creator.$1, size: 200),
          size: 44,
          isVerified: creator.$3,
          showRing: false,
        ),
        title: Row(
          children: [
            Text(
              creator.$1,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (creator.$3)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.verified_rounded,
                  color: AppColors.blue,
                  size: 13,
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${creator.$2} · Suggested for you',
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
        trailing: SizedBox(
          height: 30,
          child: FilledButton(
            onPressed: () => LocalAppState.instance.toggleFollow(
              'explore-${creator.$1}',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: following
                  ? AppColors.surfaceStrong
                  : AppColors.blue,
              foregroundColor: following ? AppColors.ink : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
            ),
            child: Text(
              following ? 'Following' : 'Follow',
              style: const TextStyle(fontSize: 11.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gridItem(PopularResult result, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(result: result)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          InstagramImage(url: _imageFor(result, index)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x66000000)],
                stops: [0.62, 1],
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  result.isVideo
                      ? Icons.play_arrow_rounded
                      : Icons.favorite_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(result.playCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          if (index == 0 && !result.isVideo)
            const Positioned(
              right: 6,
              top: 6,
              child: Icon(
                Icons.collections_rounded,
                color: Colors.white,
                size: 15,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 32,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different person, place or tag.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisualSearch() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SizedBox(
        height: 470,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Explore by photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose a post to find its creator and related posts.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(3),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: _allResults.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    final username = _allResults[index].user.username;
                    Navigator.pop(sheetContext);
                    _searchController.text = username;
                    _onSearchChanged(username);
                    _focusNode.unfocus();
                  },
                  child: InstagramImage(
                    url: _imageFor(_allResults[index], index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
