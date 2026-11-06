import 'package:flutter/material.dart';

import '../data/demo_media.dart';
import '../theme/app_theme.dart';
import 'instagram_image.dart';

class StoryItem {
  const StoryItem({
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    this.verified = false,
    this.isMine = false,
  });

  final String username;
  final String avatarUrl;
  final String imageUrl;
  final bool verified;
  final bool isMine;
}

/// Full-screen Instagram-style story player with segmented progress,
/// auto-advance, tap navigation, and a DM composer footer.
class StoryViewer extends StatefulWidget {
  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  final List<StoryItem> stories;
  final int initialIndex;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _progress.addStatusListener(_onStatus);
    _progress.forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _next();
  }

  void _next() {
    if (_index >= widget.stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index++);
    _progress.forward(from: 0);
  }

  void _previous() {
    if (_index == 0) {
      _progress.forward(from: 0);
      return;
    }
    setState(() => _index--);
    _progress.forward(from: 0);
  }

  void _hold() => _progress.stop();

  void _release() => _progress.forward();

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _hold(),
        onLongPressEnd: (_) => _release(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: InstagramImage(
                key: ValueKey(story.imageUrl),
                url: story.imageUrl,
                fit: BoxFit.cover,
                backgroundColor: Colors.black,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xAA000000),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xAA000000),
                  ],
                  stops: [0, 0.22, 0.72, 1],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                      child: Row(
                        children: [
                          for (var i = 0; i < widget.stories.length; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: AnimatedBuilder(
                                  animation: _progress,
                                  builder: (context, _) {
                                    final value = i < _index
                                        ? 1.0
                                        : i > _index
                                        ? 0.0
                                        : _progress.value;
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: value,
                                        minHeight: 2.5,
                                        backgroundColor: Colors.white30,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
                      child: Row(
                        children: [
                          InstagramAvatar(
                            url: story.avatarUrl,
                            size: 32,
                            isVerified: false,
                            showRing: false,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            story.isMine ? 'Your story' : story.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          if (story.verified)
                            const Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          const SizedBox(width: 6),
                          const Text(
                            'now',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: 100,
              bottom: 110,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _previous,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _next,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 22,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Send message',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.near_me_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 82,
              child: Row(
                children: [
                  _ViewerChip(
                    label: '${widget.stories.length - _index - 1}',
                    icon: Icons.visibility_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }
}

class _ViewerChip extends StatelessWidget {
  const _ViewerChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper used by the feed to present the viewer with a subtle fade.
Future<void> showStoryViewer(
  BuildContext context,
  List<StoryItem> stories, {
  int initialIndex = 0,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: StoryViewer(stories: stories, initialIndex: initialIndex),
      ),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
    ),
  );
}

/// Creates a list of realistic story items for the home tray.
List<StoryItem> buildDemoStories({int seed = 0}) {
  return List.generate(7, (index) {
    final i = index + seed;
    final isMine = index == 0;
    return StoryItem(
      username: isMine ? DemoMedia.profileUsername : DemoMedia.storyNames[i % 7],
      avatarUrl: isMine
          ? DemoMedia.profileAvatarSmall
          : DemoMedia.avatar(i + 1),
      imageUrl: isMine
          ? DemoMedia.soccerPhoto(i, width: 1000)
          : DemoMedia.photo(i + 2, width: 1000),
      verified: isMine || index.isEven,
      isMine: isMine,
    );
  });
}

/// The story tray at the top of the feed.
class StoryTray extends StatelessWidget {
  const StoryTray({
    super.key,
    required this.stories,
    required this.onOpen,
    required this.onAdd,
  });

  final List<StoryItem> stories;
  final void Function(int index) onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          if (index == 0) {
            return _StoryTile(
              story: story,
              onTap: onAdd,
              showAdd: true,
            );
          }
          return _StoryTile(
            story: story,
            onTap: () => onOpen(index),
            showRing: index < 4,
          );
        },
      ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({
    required this.story,
    required this.onTap,
    this.showAdd = false,
    this.showRing = true,
  });

  final StoryItem story;
  final VoidCallback onTap;
  final bool showAdd;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: InstagramAvatar(
                      url: story.avatarUrl,
                      size: 64,
                      showRing: showRing,
                      isVerified: false,
                    ),
                  ),
                  if (showAdd)
                    Positioned(
                      right: 1,
                      bottom: 2,
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              story.isMine ? 'Your story' : story.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: story.isMine ? AppColors.ink : AppColors.inkSoft,
                fontWeight: story.isMine ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
