import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../models/user.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';
import 'detail_screen.dart';
import 'post_composer_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _displayName = DemoMedia.profileName;
  String _bio = DemoMedia.profileBio;

  static const _highlights = ['Miami', 'Training', 'Matchday', 'Family', 'Brazil'];

  static const _stats = [
    ('1,284', 'posts'),
    ('231M', 'followers'),
    ('1,375', 'following'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  PopularResult _neyPost(int index, {bool isReel = false}) {
    return PopularResult(
      id: 'ney-${isReel ? 'reel' : 'post'}-$index',
      position: index + 1,
      shortcode: 'ney$index',
      link: 'https://www.instagram.com/neymarjr/',
      displayUrl: DemoMedia.soccerPhoto(index, width: 1000),
      caption: isReel
          ? DemoMedia.reelCaptions[index % DemoMedia.reelCaptions.length]
          : DemoMedia.soccerCaptions[index % DemoMedia.soccerCaptions.length],
      user: User(
        id: 'me',
        isVerified: true,
        profilePicUrl: DemoMedia.profileAvatarSmall,
        username: DemoMedia.profileUsername,
        link: 'https://www.instagram.com/neymarjr/',
      ),
      playCount: 1240000 + index * 312000,
      videoVersions: isReel ? [DemoMedia.reelVideo(index)] : const [],
    );
  }

  PopularResult _taggedPost(int index) {
    return PopularResult(
      id: 'tagged-$index',
      position: index + 1,
      shortcode: 'tag$index',
      link: 'https://www.instagram.com/',
      displayUrl: DemoMedia.soccerPhoto(index + 5, width: 900),
      caption: 'With the GOAT ⚽️',
      user: User(
        id: 'tag-user-$index',
        isVerified: index.isEven,
        profilePicUrl: DemoMedia.avatar(index + 2),
        username: const [
          'vinijr',
          'leomessi',
          'alhilal',
          'psg',
          'brasil',
          'football',
        ][index % 6],
        link: 'https://www.instagram.com/',
      ),
      playCount: 450000 + index * 80000,
      videoVersions: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              titleSpacing: 16,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      _displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.blue,
                    size: 16,
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.ink,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'New post',
                  onPressed: () => _openComposer('post'),
                  icon: const Icon(Icons.add_box_outlined, size: 25),
                ),
                IconButton(
                  tooltip: 'Menu',
                  onPressed: _showMenu,
                  icon: const Icon(Icons.menu_rounded, size: 25),
                ),
                const SizedBox(width: 2),
              ],
            ),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: LocalAppState.instance,
                builder: (context, _) => _profileHeader(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabHeader(
                TabBar(
                  controller: _tabs,
                  indicatorWeight: 1.4,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.ink,
                  unselectedLabelColor: AppColors.faint,
                  dividerColor: AppColors.line,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on_rounded, size: 22)),
                    Tab(icon: Icon(Icons.smart_display_outlined, size: 23)),
                    Tab(icon: Icon(Icons.person_pin_outlined, size: 23)),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [
              _postGrid(reels: false),
              _postGrid(reels: true),
              _taggedView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              _avatarWithRing(),
              const SizedBox(width: 16),
              for (final stat in _stats)
                Expanded(child: _stat(stat.$1, stat.$2)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.blue,
                    size: 14,
                  ),
                ],
              ),
              const Text(
                'Footballer · Athlete',
                style: TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              Text(
                _bio,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.link_rounded, size: 13, color: Color(0xFF00376B)),
                  SizedBox(width: 3),
                  Text(
                    DemoMedia.profileLink,
                    style: TextStyle(
                      color: Color(0xFF00376B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _button('Edit profile', onTap: _editProfile)),
              const SizedBox(width: 7),
              Expanded(child: _button('Share profile', onTap: _shareProfile)),
              const SizedBox(width: 7),
              SizedBox(
                width: 40,
                child: _button(
                  '',
                  icon: Icons.person_add_alt_1_rounded,
                  onTap: _discoverPeople,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 98,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            children: [
              _highlight(null, 'New', add: true),
              for (var i = 0; i < _highlights.length; i++)
                _highlight(DemoMedia.highlight(i, size: 180), _highlights[i]),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _avatarWithRing() {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.story,
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          InstagramAvatar(
            url: DemoMedia.profileAvatarSmall,
            size: 80,
            showRing: false,
          ),
          Positioned(
            right: 3,
            bottom: 3,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 17,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
      ),
      const SizedBox(height: 1),
      Text(
        label,
        style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
      ),
    ],
  );

  Widget _button(String label, {IconData? icon, required VoidCallback onTap}) =>
      SizedBox(
        height: 34,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          child: icon == null
              ? Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                )
              : Icon(icon, size: 18),
        ),
      );

  Widget _highlight(String? image, String title, {bool add = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: GestureDetector(
      onTap: () {
        if (add) {
          _openComposer('story');
        } else if (image != null) {
          _openImage(image, title);
        }
      },
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line, width: 1),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: add
                    ? Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.add_rounded,
                          size: 26,
                          color: AppColors.ink,
                        ),
                      )
                    : InstagramImage(
                        url: image,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _postGrid({required bool reels}) => AnimatedBuilder(
    animation: LocalAppState.instance,
    builder: (context, _) => _postGridContent(reels: reels),
  );

  Widget _postGridContent({required bool reels}) {
    final own = reels
        ? LocalAppState.instance.reels
        : LocalAppState.instance.posts;
    final demo = List.generate(12, (index) => _neyPost(index, isReel: reels));
    final posts = [...own, ...demo];

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final image = post.displayUrl.isNotEmpty
            ? post.displayUrl
            : DemoMedia.soccerPhoto(index);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(result: post)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              InstagramImage(url: image),
              if (reels || post.videoVersions.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              if (index == 0 && !reels)
                Positioned(
                  left: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.collections_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _taggedView() => GridView.builder(
    padding: const EdgeInsets.all(2),
    physics: const BouncingScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    ),
    itemCount: 9,
    itemBuilder: (context, index) {
      final post = _taggedPost(index);
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(result: post)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InstagramImage(url: post.displayUrl),
            Positioned(
              right: 5,
              bottom: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_pin_outlined,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    post.user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  void _openImage(String image, String title) => showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InstagramImage(
            url: image,
            fit: BoxFit.contain,
            backgroundColor: Colors.black,
          ),
          Positioned(
            top: 35,
            left: 16,
            right: 16,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Highlights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 28,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
  );

  Future<void> _openComposer(String type) async {
    final shared = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PostComposerScreen(type: type)),
    );
    if (mounted && shared == true) {
      _toast(type == 'story' ? 'Story added' : '$type shared');
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _displayName);
    final bioController = TextEditingController(text: _bio);
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (changed == true && mounted) {
      setState(() {
        _displayName = nameController.text.trim().isEmpty
            ? _displayName
            : nameController.text.trim();
        _bio = bioController.text.trim();
      });
      _toast('Profile updated');
    }
    nameController.dispose();
    bioController.dispose();
  }

  Future<void> _shareProfile() async {
    await Clipboard.setData(
      const ClipboardData(text: 'https://www.instagram.com/neymarjr/'),
    );
    if (mounted) _toast('Profile link copied');
  }

  void _discoverPeople() {
    const suggestions = [
      ('vinijr', 'Followed by neymarjr + 12 others'),
      ('leomessi', 'Followed by neymarjr + 31 others'),
      ('alhilal', 'Suggested for you'),
      ('brasil', 'Suggested for you'),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AnimatedBuilder(
        animation: LocalAppState.instance,
        builder: (context, _) => SafeArea(
          child: SizedBox(
            height: 440,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Discover people',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                for (var i = 0; i < suggestions.length; i++)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: InstagramAvatar(
                      url: DemoMedia.avatar(i + 1),
                      size: 46,
                      showRing: false,
                    ),
                    title: Row(
                      children: [
                        Text(
                          suggestions[i].$1,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (i < 2)
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
                      suggestions[i].$2,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                    trailing: FilledButton(
                      onPressed: () => LocalAppState.instance.toggleFollow(
                        'suggested-${suggestions[i].$1}',
                      ),
                      child: Text(
                        LocalAppState.instance.isFollowing(
                              'suggested-${suggestions[i].$1}',
                            )
                            ? 'Following'
                            : 'Follow',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSaved() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AnimatedBuilder(
      animation: LocalAppState.instance,
      builder: (context, _) {
        final saved = [
          ...LocalAppState.instance.posts,
          ...List.generate(12, _neyPost),
        ].where((post) => LocalAppState.instance.isSaved(post.id)).toList();
        return SafeArea(
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: saved.isEmpty
                      ? const Center(
                          child: Text('Posts you save will appear here.'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(3),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                              ),
                          itemCount: saved.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(result: saved[index]),
                              ),
                            ),
                            child: InstagramImage(
                              url: saved[index].displayUrl,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  void _showAccountOption(String title) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(switch (title) {
        'Settings and privacy' =>
          'Manage your account preferences and privacy options.',
        'Archive' => 'Stories and posts you archive will appear here.',
        'Insights' => 'Your account reached 231M followers this month.',
        _ => 'Your profile QR code is ready to share.',
      }),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  void _showMenu() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              _displayName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          for (final item in const [
            (Icons.settings_outlined, 'Settings and privacy'),
            (Icons.archive_outlined, 'Archive'),
            (Icons.insights_outlined, 'Insights'),
            (Icons.bookmark_border_rounded, 'Saved'),
            (Icons.qr_code_rounded, 'QR code'),
          ])
            ListTile(
              leading: Icon(item.$1, size: 22),
              title: Text(item.$2, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.faint,
              ),
              onTap: () {
                Navigator.pop(context);
                if (item.$2 == 'Saved') {
                  _showSaved();
                } else {
                  _showAccountOption(item.$2);
                }
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

class _TabHeader extends SliverPersistentHeaderDelegate {
  _TabHeader(this.child);

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: 48, width: double.infinity, child: child);

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabHeader oldDelegate) => false;
}
