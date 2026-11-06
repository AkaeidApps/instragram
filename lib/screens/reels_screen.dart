import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../models/user.dart';
import '../services/instagram_service.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';
import '../widgets/reel_video_player.dart';
import 'post_composer_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, this.isActive = true});

  /// True while the Reels tab is the visible tab. Used to pause playback when
  /// the user navigates to another tab.
  final bool isActive;

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<PopularResult> _reels = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isMuted = true;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      final response = await InstagramService.searchPopular('austin');
      if (!mounted) return;
      setState(() {
        _reels = response.popularResults.isNotEmpty
            ? response.popularResults
            : _demoReels();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reels = _demoReels();
        _isLoading = false;
      });
    }
  }

  List<PopularResult> _demoReels() {
    return List.generate(6, (index) {
      return PopularResult(
        id: 'reel-$index',
        position: index + 1,
        shortcode: 'reel$index',
        link: 'https://www.instagram.com/',
        displayUrl: DemoMedia.soccerPhoto(index + 1),
        caption: DemoMedia.reelCaptions[index],
        user: User(
          id: 'reel-user-$index',
          isVerified: index.isEven,
          profilePicUrl: DemoMedia.avatar(index + 2),
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
        playCount: 184000 + index * 92000,
        videoVersions: [DemoMedia.reelVideo(index)],
      );
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : AnimatedBuilder(
              animation: LocalAppState.instance,
              builder: (context, _) {
                final reels = [...LocalAppState.instance.reels, ..._reels];
                if (reels.isEmpty) return _emptyState();
                final activeIndex = _currentIndex.clamp(0, reels.length - 1);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: reels.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final reel = reels[index];
                        return _ReelPage(
                          key: ValueKey(reel.id),
                          reel: reel,
                          index: index,
                          total: reels.length,
                          isActive: widget.isActive && index == activeIndex,
                          isMuted: _isMuted,
                          onToggleMute: () =>
                              setState(() => _isMuted = !_isMuted),
                          videoUrl: DemoMedia.playableVideoFor(
                            seed: reel.id,
                            sources: reel.videoVersions,
                          ),
                          posterUrl: reel.displayUrl.isNotEmpty
                              ? reel.displayUrl
                              : DemoMedia.photo(index + 3),
                          onComment: () => _showComments(reel),
                          onShare: () => _shareReel(reel),
                          onMore: () => _showReelMenu(reel),
                          onComposer: _openReelComposer,
                          formatCount: _formatCount,
                        );
                      },
                    ),
                    _topBar(reels.length, activeIndex),
                  ],
                );
              },
            ),
    );
  }

  Widget _topBar(int total, int activeIndex) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 10, 8),
          child: Row(
            children: [
              const Text(
                'Reels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${activeIndex + 1}/$total',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _GlassIconButton(
                icon: _isMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                tooltip: _isMuted ? 'Unmute' : 'Mute',
                onTap: () => setState(() => _isMuted = !_isMuted),
              ),
              const SizedBox(width: 6),
              _GlassIconButton(
                icon: Icons.camera_alt_outlined,
                tooltip: 'Create reel',
                onTap: _openReelComposer,
              ),
            ],
          ),
        ),
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
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.6),
              ),
              child: const Icon(
                Icons.smart_display_outlined,
                color: Colors.white70,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No reels yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Share your first reel and it will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _openReelComposer,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create reel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openReelComposer() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PostComposerScreen(type: 'reel')),
    );
  }

  void _showComments(PopularResult reel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReelCommentsSheet(reel: reel),
    );
  }

  Future<void> _shareReel(PopularResult reel) async {
    await Clipboard.setData(ClipboardData(text: reel.link));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reel link copied')));
    }
  }

  void _showReelMenu(PopularResult reel) => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_border_rounded),
            title: Text(
              LocalAppState.instance.isSaved(reel.id)
                  ? 'Remove from saved'
                  : 'Save reel',
            ),
            onTap: () {
              LocalAppState.instance.toggleSaved(reel.id);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.link_rounded),
            title: const Text('Copy link'),
            onTap: () {
              Navigator.pop(context);
              _shareReel(reel);
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_off_rounded),
            title: const Text('Mute this reel'),
            onTap: () {
              setState(() => _isMuted = true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('Report received')));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _ReelPage extends StatelessWidget {
  const _ReelPage({
    super.key,
    required this.reel,
    required this.index,
    required this.total,
    required this.isActive,
    required this.isMuted,
    required this.onToggleMute,
    required this.videoUrl,
    required this.posterUrl,
    required this.onComment,
    required this.onShare,
    required this.onMore,
    required this.onComposer,
    required this.formatCount,
  });

  final PopularResult reel;
  final int index;
  final int total;
  final bool isActive;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final String? videoUrl;
  final String posterUrl;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final VoidCallback onComposer;
  final String Function(int) formatCount;

  @override
  Widget build(BuildContext context) {
    final appState = LocalAppState.instance;
    final isLiked = appState.isLiked(reel.id);
    final isSaved = appState.isSaved(reel.id);
    final isFollowing = appState.isFollowing(reel.user.id);
    final username = reel.user.username.isEmpty
        ? 'instagram'
        : reel.user.username;
    final avatar = reel.user.profilePicUrl.isNotEmpty
        ? reel.user.profilePicUrl
        : DemoMedia.avatarFor(username);

    return Stack(
      fit: StackFit.expand,
      children: [
        ReelVideoPlayer(
          videoUrl: videoUrl,
          posterUrl: posterUrl,
          isActive: isActive,
          isMuted: isMuted,
          onDoubleTapLike: () {
            if (!appState.isLiked(reel.id)) appState.toggleLike(reel.id);
          },
        ),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.reelScrim),
          ),
        ),
        if (isMuted && index == 0 && isActive)
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onToggleMute,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volume_off_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Tap for sound',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Right action rail
        Positioned(
          right: 9,
          bottom: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => appState.toggleFollow(reel.user.id),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InstagramAvatar(
                      url: avatar,
                      size: 44,
                      isVerified: reel.user.isVerified,
                      showRing: false,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -8,
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isFollowing
                                ? AppColors.surfaceStrong
                                : AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            isFollowing
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            color: isFollowing ? AppColors.ink : Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _RailAction(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isLiked ? AppColors.red : Colors.white,
                label: formatCount(reel.playCount + (isLiked ? 1 : 0)),
                onTap: () => appState.toggleLike(reel.id),
              ),
              _RailAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: formatCount(
                  38 + (appState.commentsByPost[reel.id]?.length ?? 0),
                ),
                onTap: onComment,
              ),
              _RailAction(
                icon: Icons.near_me_outlined,
                label: formatCount(reel.playCount ~/ 120),
                onTap: onShare,
              ),
              _RailAction(
                icon: isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: '',
                onTap: () => appState.toggleSaved(reel.id),
              ),
              _RailAction(
                icon: Icons.more_horiz_rounded,
                label: '',
                onTap: onMore,
              ),
              const SizedBox(height: 8),
              _MusicDisc(imageUrl: avatar),
            ],
          ),
        ),
        // Caption + metadata
        Positioned(
          left: 14,
          right: 76,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (reel.user.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                  const SizedBox(width: 8),
                  _FollowPill(
                    following: isFollowing,
                    onTap: () => appState.toggleFollow(reel.user.id),
                  ),
                ],
              ),
              if ((reel.caption ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reel.caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Original audio · $username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onComposer,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RailAction extends StatelessWidget {
  const _RailAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.28),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

class _FollowPill extends StatelessWidget {
  const _FollowPill({required this.onTap, required this.following});

  final VoidCallback onTap;
  final bool following;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          following ? 'Following' : 'Follow',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ReelCommentsSheet extends StatefulWidget {
  const _ReelCommentsSheet({required this.reel});

  final PopularResult reel;

  @override
  State<_ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<_ReelCommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext sheetContext) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    LocalAppState.instance.addComment(widget.reel.id, text);
    _controller.clear();
    FocusScope.of(sheetContext).unfocus();
  }

  @override
  Widget build(BuildContext sheetContext) {
    return AnimatedBuilder(
      animation: LocalAppState.instance,
      builder: (context, _) {
        final comments =
            LocalAppState.instance.commentsByPost[widget.reel.id] ??
            const <String>[];
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 440,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${38 + comments.length}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: [
                      for (final comment in comments)
                        _CommentTile(
                          avatarUrl: DemoMedia.profileAvatar,
                          name: DemoMedia.profileUsername,
                          text: comment,
                          time: 'now',
                          verified: true,
                        ),
                      const _CommentTile(
                        avatarUrl: '',
                        name: 'austin.life',
                        text: 'Such a beautiful moment ✨',
                        time: '2h',
                      ),
                      const _CommentTile(
                        avatarUrl: '',
                        name: 'travel.diary',
                        text: 'Love this!',
                        time: '3h',
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Row(
                    children: [
                      InstagramAvatar(
                        url: DemoMedia.profileAvatarSmall,
                        size: 32,
                        showRing: false,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submit(sheetContext),
                          decoration: const InputDecoration(
                            hintText: 'Add a comment…',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _submit(sheetContext),
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.blue,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.avatarUrl,
    required this.name,
    required this.text,
    required this.time,
    this.verified = false,
  });

  final String avatarUrl;
  final String name;
  final String text;
  final String time;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InstagramAvatar(
            url: avatarUrl.isEmpty ? null : avatarUrl,
            size: 32,
            isVerified: verified,
            showRing: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: text),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$time  ·  Reply',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.favorite_border_rounded,
            size: 16,
            color: AppColors.faint,
          ),
        ],
      ),
    );
  }
}

class _MusicDisc extends StatefulWidget {
  const _MusicDisc({required this.imageUrl});

  final String imageUrl;

  @override
  State<_MusicDisc> createState() => _MusicDiscState();
}

class _MusicDiscState extends State<_MusicDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: ClipOval(
          child: InstagramImage(url: widget.imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
