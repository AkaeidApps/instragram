import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';
import '../widgets/reel_video_player.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.result});

  final PopularResult result;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _muted = true;

  bool get _liked => LocalAppState.instance.isLiked(_post.id);
  bool get _saved => LocalAppState.instance.isSaved(_post.id);
  List<String> get _comments =>
      LocalAppState.instance.commentsByPost[_post.id] ?? const [];

  PopularResult get _post => widget.result;

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final username = _post.user.username.isEmpty
        ? 'instagram'
        : _post.user.username;
    final avatar = _post.user.profilePicUrl.isNotEmpty
        ? _post.user.profilePicUrl
        : DemoMedia.avatarFor(username);
    final videoUrl = _post.isVideo
        ? DemoMedia.playableVideoFor(
            seed: _post.id,
            sources: _post.videoVersions,
          )
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: videoUrl != null ? 430 : 340,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            foregroundColor: AppColors.ink,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              if (videoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _CircleButton(
                    icon: _muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    onTap: () => setState(() => _muted = !_muted),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _CircleButton(
                  icon: Icons.near_me_outlined,
                  onTap: _copyPostLink,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _CircleButton(
                  icon: Icons.more_horiz_rounded,
                  onTap: _showMoreOptions,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (videoUrl != null)
                    ReelVideoPlayer(
                      videoUrl: videoUrl,
                      posterUrl: _post.displayUrl.isNotEmpty
                          ? _post.displayUrl
                          : DemoMedia.photoFor(_post.id),
                      isActive: true,
                      isMuted: _muted,
                      onDoubleTapLike: () {
                        if (!LocalAppState.instance.isLiked(_post.id)) {
                          setState(
                            () => LocalAppState.instance.toggleLike(_post.id),
                          );
                        }
                      },
                    )
                  else
                    InstagramImage(
                      url: _post.displayUrl.isNotEmpty
                          ? _post.displayUrl
                          : DemoMedia.photoFor(_post.id),
                    ),
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Colors.transparent],
                          stops: [0, 0.28],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                  child: Row(
                    children: [
                      InstagramAvatar(
                        url: avatar,
                        size: 36,
                        isVerified: _post.user.isVerified,
                        showRing: false,
                        onTap: _showAuthorPreview,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    username,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
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
                                      size: 14,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 11,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _post.isVideo
                                      ? 'Reels · Austin, Texas'
                                      : 'Austin, Texas',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(
                          () => LocalAppState.instance.toggleFollow(
                            _post.user.id,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.line),
                          backgroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          LocalAppState.instance.isFollowing(_post.user.id)
                              ? 'Following'
                              : 'Follow',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    children: [
                      Icon(
                        _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _liked ? AppColors.red : AppColors.ink,
                        size: 21,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatCount(_post.playCount + (_liked ? 1 : 0))} ${_post.isVideo ? 'plays' : 'likes'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 19,
                        color: AppColors.inkSoft,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${38 + _comments.length} comments',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((_post.caption ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$username ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: _post.caption!.trim()),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Align(
                          widthFactor: 0.7,
                          child: InstagramAvatar(
                            url: DemoMedia.avatar(i + 2),
                            size: 20,
                            showRing: false,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Liked by ',
                                style: TextStyle(color: AppColors.inkSoft),
                              ),
                              TextSpan(
                                text: 'austin.life',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text:
                                    '${_formatCount(_post.playCount ~/ 3)} others',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text(
                    '2 hours ago · Austin, Texas',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.faint,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Text('COMMENTS', style: AppTheme.sectionLabel),
                ),
                for (final comment in _comments)
                  _CommentRow(
                    name: DemoMedia.profileUsername,
                    avatarUrl: DemoMedia.profileAvatarSmall,
                    verified: true,
                    text: comment,
                    time: 'now',
                  ),
                const _CommentRow(
                  name: 'austin.life',
                  text: 'This is such a beautiful shot 😍 saving this spot.',
                  time: '1h',
                ),
                const _CommentRow(
                  name: 'travel.diary',
                  text: 'The light in this is unreal. What camera do you use?',
                  time: '2h',
                ),
                const _CommentRow(
                  name: 'daily.escape',
                  text: 'Adding this to the weekend list right now.',
                  time: '3h',
                ),
                const SizedBox(height: 18),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _post.isVideo ? 'View reel insights' : 'View insights',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'POSTED 2 HOURS AGO',
                        style: TextStyle(
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(
                  () => LocalAppState.instance.toggleLike(_post.id),
                ),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _liked ? AppColors.red : AppColors.ink,
                  size: 26,
                ),
              ),
              IconButton(
                onPressed: _focusComment,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment…',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              IconButton(
                onPressed: _sendComment,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.send_rounded, size: 22),
              ),
              IconButton(
                onPressed: () => setState(
                  () => LocalAppState.instance.toggleSaved(_post.id),
                ),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendComment() {
    final value = _commentController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      LocalAppState.instance.addComment(_post.id, value);
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _focusComment() =>
      FocusScope.of(context).requestFocus(_commentFocusNode);

  void _showAuthorPreview() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InstagramAvatar(
                url: _post.user.profilePicUrl.isNotEmpty
                    ? _post.user.profilePicUrl
                    : DemoMedia.avatarFor(_post.user.username),
                size: 76,
                showRing: true,
              ),
              const SizedBox(height: 10),
              Text(
                _post.user.username,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Digital creator · Austin, TX',
                style: TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        LocalAppState.instance.toggleFollow(_post.user.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        LocalAppState.instance.isFollowing(_post.user.id)
                            ? 'Following'
                            : 'Follow',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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

  Future<void> _copyPostLink() async {
    await Clipboard.setData(ClipboardData(text: _post.link));
    if (mounted) _toast('Post link copied');
  }

  void _showMoreOptions() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_border_rounded),
            title: Text(_saved ? 'Remove from saved' : 'Save'),
            onTap: () {
              Navigator.pop(context);
              setState(() => LocalAppState.instance.toggleSaved(_post.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.link_rounded),
            title: const Text('Copy link'),
            onTap: () {
              Navigator.pop(context);
              _copyPostLink();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share to…'),
            onTap: () {
              Navigator.pop(context);
              _copyPostLink();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              _toast('Report submitted');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
  );
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.name,
    required this.text,
    required this.time,
    this.avatarUrl,
    this.verified = false,
  });

  final String name;
  final String text;
  final String time;
  final String? avatarUrl;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InstagramAvatar(
            url: avatarUrl ?? DemoMedia.avatarFor(name),
            size: 30,
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}
