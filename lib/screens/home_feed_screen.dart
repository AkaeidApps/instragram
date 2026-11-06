import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../models/user.dart';
import '../services/instagram_service.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';
import '../widgets/story_viewer.dart';
import 'detail_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'post_composer_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  List<PopularResult> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final response = await InstagramService.searchPopular('austin');
      if (!mounted) return;
      setState(() {
        _posts = response.popularResults.isNotEmpty
            ? response.popularResults
            : _demoPosts();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _posts = _demoPosts();
          _isLoading = false;
        });
      }
    }
  }

  List<PopularResult> _demoPosts() {
    return List.generate(6, (index) {
      return PopularResult(
        id: 'demo-$index',
        position: index + 1,
        shortcode: 'demo$index',
        link: 'https://www.instagram.com/',
        displayUrl: DemoMedia.photo(index + 2),
        caption: DemoMedia.captions[index % DemoMedia.captions.length],
        user: User(
          id: 'demo-user-$index',
          isVerified: index.isEven,
          profilePicUrl: DemoMedia.avatar(index + 1),
          username: const [
            'paulina.perez',
            'austin.life',
            'travel.diary',
            'daily.escape',
            'maria',
            'neymarjr',
          ][index],
          link: 'https://www.instagram.com/',
        ),
        playCount: 2481 + index * 18340,
        videoVersions: index == 1
            ? [DemoMedia.reelVideo(1)]
            : const [],
      );
    });
  }

  String _imageFor(PopularResult post, int index) {
    if (post.displayUrl.isEmpty) return DemoMedia.photoFor(post.id);
    if (post.displayUrl.contains('cdninstagram')) {
      return DemoMedia.photo(index + 1);
    }
    return post.displayUrl;
  }

  List<StoryItem> _stories() {
    final local = LocalAppState.instance.stories;
    final selfImage = local.isNotEmpty
        ? local.first.imageUrl
        : DemoMedia.soccerPhoto(0, width: 1000);
    return [
      StoryItem(
        username: DemoMedia.profileUsername,
        avatarUrl: DemoMedia.profileAvatarSmall,
        imageUrl: selfImage,
        verified: true,
        isMine: true,
      ),
      ...buildDemoStories(seed: 1).skip(1),
    ];
  }

  void _openStory(int index) {
    final stories = _stories();
    if (index <= 0) return;
    showStoryViewer(context, stories, initialIndex: index);
  }

  Future<void> _openComposer(String type) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PostComposerScreen(type: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16,
        title: ShaderMask(
          shaderCallback: (bounds) => AppGradients.brand.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Instagram',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              letterSpacing: -1.2,
            ),
          ),
        ),
        actions: [
          _AppBarAction(
            tooltip: 'Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: Icons.favorite_border_rounded,
            badge: true,
          ),
          _AppBarAction(
            tooltip: 'Messages',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessagesScreen()),
            ),
            icon: Icons.near_me_outlined,
            badge: true,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const _FeedSkeleton()
          : AnimatedBuilder(
              animation: LocalAppState.instance,
              builder: (context, _) => RefreshIndicator(
                onRefresh: _loadPosts,
                color: AppColors.ink,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    StoryTray(
                      stories: _stories(),
                      onOpen: _openStory,
                      onAdd: () => _openComposer('story'),
                    ),
                    const Divider(),
                    if (LocalAppState.instance.posts.isNotEmpty) ...[
                      for (var i = 0; i < LocalAppState.instance.posts.length; i++)
                        _PostCard(
                          post: LocalAppState.instance.posts[i],
                          imageUrl: _imageFor(
                            LocalAppState.instance.posts[i],
                            i,
                          ),
                          onOpen: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  result: LocalAppState.instance.posts[i],
                                ),
                              ),
                            );
                          },
                          onShare: _sharePost,
                          onMenu: _showPostMenu,
                          onAuthor: _showUserPreview,
                        ),
                    ],
                    for (var i = 0; i < _posts.length; i++)
                      _PostCard(
                        post: _posts[i],
                        imageUrl: _imageFor(_posts[i], i),
                        onOpen: () => _openPost(_posts[i]),
                        onShare: _sharePost,
                        onMenu: _showPostMenu,
                        onAuthor: _showUserPreview,
                      ),
                    const SizedBox(height: 12),
                    _caughtUp(),
                    const SizedBox(height: 22),
                    const Divider(),
                    _suggested(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _caughtUp() => Center(
    child: Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.ink,
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'You’re all caught up',
          style: TextStyle(
            color: AppColors.inkSoft,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'You’ve seen all new posts from the past 3 days.',
          style: TextStyle(color: AppColors.muted, fontSize: 11.5),
        ),
      ],
    ),
  );

  Widget _suggested() {
    const names = ['vinijr', 'leomessi', 'alhilal', 'brasil', 'psg', 'football'];
    return AnimatedBuilder(
      animation: LocalAppState.instance,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text('SUGGESTED FOR YOU', style: AppTheme.sectionLabel),
          ),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: names.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final name = names[index];
                final following = LocalAppState.instance.isFollowing(
                  'suggested-$name',
                );
                return SizedBox(
                  width: 104,
                  child: Column(
                    children: [
                      InstagramAvatar(
                        url: DemoMedia.avatarFor(name, size: 200),
                        size: 64,
                        showRing: index.isEven,
                        isVerified: index < 2,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Suggested for you',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 7),
                      SizedBox(
                        height: 28,
                        child: FilledButton(
                          onPressed: () => LocalAppState.instance.toggleFollow(
                            'suggested-$name',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: following
                                ? AppColors.surfaceStrong
                                : AppColors.blue,
                            foregroundColor: following
                                ? AppColors.ink
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            following ? 'Following' : 'Follow',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPost(PopularResult post) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DetailScreen(result: post)),
  );

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
  );

  Future<void> _sharePost(PopularResult post) async {
    await Clipboard.setData(ClipboardData(text: post.link));
    if (mounted) _toast('Post link copied');
  }

  void _showUserPreview(PopularResult post) {
    if (post.user.username.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: InstagramAvatar(
                  url: post.user.profilePicUrl.isNotEmpty
                      ? post.user.profilePicUrl
                      : DemoMedia.avatarFor(post.user.username),
                  size: 74,
                  showRing: true,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (post.user.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified_rounded,
                          color: AppColors.blue,
                          size: 15,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Digital creator · Austin, TX',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        LocalAppState.instance.toggleFollow(post.user.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        LocalAppState.instance.isFollowing(post.user.id)
                            ? 'Following'
                            : 'Follow',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MessagesScreen(),
                          ),
                        );
                      },
                      child: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostMenu(PopularResult post) => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_border_rounded),
            title: Text(
              LocalAppState.instance.isSaved(post.id)
                  ? 'Remove from saved'
                  : 'Save',
            ),
            onTap: () {
              Navigator.pop(context);
              LocalAppState.instance.toggleSaved(post.id);
              _toast(
                LocalAppState.instance.isSaved(post.id)
                    ? 'Saved'
                    : 'Removed from saved',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.link_rounded),
            title: const Text('Copy link'),
            onTap: () {
              Navigator.pop(context);
              _sharePost(post);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle_outline_rounded),
            title: Text(
              LocalAppState.instance.isFollowing(post.user.id)
                  ? 'Unfollow @${post.user.username}'
                  : 'Follow @${post.user.username}',
            ),
            onTap: () {
              Navigator.pop(context);
              LocalAppState.instance.toggleFollow(post.user.id);
              _toast(
                LocalAppState.instance.isFollowing(post.user.id)
                    ? 'Following @${post.user.username}'
                    : 'Unfollowed @${post.user.username}',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_gmailerrorred_rounded),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              _toast('Report post');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 26),
          if (badge)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({
    required this.post,
    required this.imageUrl,
    required this.onOpen,
    required this.onShare,
    required this.onMenu,
    required this.onAuthor,
  });

  final PopularResult post;
  final String imageUrl;
  final VoidCallback onOpen;
  final ValueChanged<PopularResult> onShare;
  final ValueChanged<PopularResult> onMenu;
  final ValueChanged<PopularResult> onAuthor;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heart;

  PopularResult get _post => widget.post;

  @override
  void initState() {
    super.initState();
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _heart.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  void _like() {
    HapticFeedback.lightImpact();
    if (!LocalAppState.instance.isLiked(_post.id)) {
      LocalAppState.instance.toggleLike(_post.id);
    }
    _heart.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = LocalAppState.instance;
    final isLiked = state.isLiked(_post.id);
    final isSaved = state.isSaved(_post.id);
    final username = _post.user.username.isEmpty
        ? 'instagram'
        : _post.user.username;
    final caption = (_post.caption ?? '').trim();
    final avatar = _post.user.profilePicUrl.isNotEmpty
        ? _post.user.profilePicUrl
        : DemoMedia.avatarFor(username);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.onAuthor(_post),
                child: InstagramAvatar(
                  url: avatar,
                  size: 34,
                  isVerified: _post.user.isVerified,
                  showRing: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onAuthor(_post),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (_post.user.isVerified)
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
                      const SizedBox(height: 1),
                      const Text(
                        'Austin, Texas',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => widget.onMenu(_post),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
        GestureDetector(
          onDoubleTap: _like,
          onTap: widget.onOpen,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                InstagramImage(url: widget.imageUrl),
                AnimatedBuilder(
                  animation: _heart,
                  builder: (context, _) {
                    final progress = _heart.value;
                    if (progress == 0 || progress == 1) {
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: Opacity(
                        opacity: (1 - progress).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.55 + progress * 1.05,
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 110,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_post.isVideo)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Reel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      state.toggleLike(_post.id);
                    },
                    visualDensity: VisualDensity.compact,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(isLiked),
                        color: isLiked ? AppColors.red : AppColors.ink,
                        size: 26,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onOpen,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onShare(_post),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.near_me_outlined, size: 24),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => state.toggleSaved(_post.id),
                    visualDensity: VisualDensity.compact,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        key: ValueKey(isSaved),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${_formatCount(_post.playCount + (isLiked ? 1 : 0))} likes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$username ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: caption),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: GestureDetector(
                  onTap: widget.onOpen,
                  child: Text(
                    'View all ${38 + (state.commentsByPost[_post.id]?.length ?? 0)} comments',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Text(
                  '2 HOURS AGO',
                  style: TextStyle(
                    color: AppColors.faint,
                    fontSize: 10,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceStrong,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 50,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        for (var i = 0; i < 2; i++) ...[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceStrong,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 70,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(color: AppColors.surfaceStrong),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
