import 'package:flutter/material.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../models/user.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';
import 'detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _items = [
    (
      'austin.life',
      'liked your photo.',
      '2h',
      Icons.favorite_rounded,
      AppColors.red,
    ),
    (
      'travel.diary',
      'started following you.',
      '4h',
      Icons.person_add_alt_1_rounded,
      AppColors.blue,
    ),
    (
      'daily.escape',
      'commented: “This is unreal 🔥”',
      '6h',
      Icons.chat_bubble_rounded,
      AppColors.green,
    ),
    (
      'maria',
      'mentioned you in a story.',
      '9h',
      Icons.alternate_email_rounded,
      AppColors.purple,
    ),
    (
      'vinijr',
      'liked your reel.',
      '1d',
      Icons.favorite_rounded,
      AppColors.red,
    ),
    (
      'alhilal',
      'tagged you in a photo.',
      '1d',
      Icons.person_pin_rounded,
      AppColors.orange,
    ),
    (
      'leomessi',
      'started following you.',
      '2d',
      Icons.person_add_alt_1_rounded,
      AppColors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  PopularResult _post(int index) => PopularResult(
    id: 'notif-post-$index',
    position: index + 1,
    shortcode: 'notif$index',
    link: 'https://www.instagram.com/',
    displayUrl: DemoMedia.photo(index + 1),
    caption: DemoMedia.captions[index % DemoMedia.captions.length],
    user: User(
      id: 'notif-user-$index',
      isVerified: index.isEven,
      profilePicUrl: DemoMedia.avatar(index + 1),
      username: _items[index].$1,
      link: 'https://www.instagram.com/',
    ),
    playCount: 12000 + index * 5000,
    videoVersions: const [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 8,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Notification settings',
            onPressed: () => _toast('Notification settings opened'),
            icon: const Icon(Icons.tune_rounded, size: 22),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Follows'),
            Tab(text: 'You'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _list(_items),
          _list(_items.where((item) => item.$4 == Icons.person_add_alt_1_rounded).toList()),
          _list(_items.where((item) => item.$4 == Icons.favorite_rounded || item.$4 == Icons.chat_bubble_rounded).toList()),
        ],
      ),
    );
  }

  Widget _list(List<(String, String, String, IconData, Color)> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nothing here yet',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    final indexOffset = _items.indexOf(items.first);
    return AnimatedBuilder(
      animation: LocalAppState.instance,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (items.length > 3)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text('THIS WEEK', style: AppTheme.sectionLabel),
            ),
          for (var i = 0; i < items.length; i++)
            _row(items[i], indexOffset + i),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _row(
    (String, String, String, IconData, Color) item,
    int index,
  ) {
    final following = LocalAppState.instance.isFollowing('notif-$index');
    final post = _post(index);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(result: post)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                InstagramAvatar(
                  url: DemoMedia.avatar(index + 1),
                  size: 44,
                  showRing: false,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: item.$5,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.6),
                    ),
                    child: Icon(item.$4, color: Colors.white, size: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' ${item.$2}',
                          style: const TextStyle(color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$3,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (item.$4 == Icons.person_add_alt_1_rounded)
              SizedBox(
                height: 30,
                child: FilledButton(
                  onPressed: () =>
                      LocalAppState.instance.toggleFollow('notif-$index'),
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
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: InstagramImage(url: post.displayUrl),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}
