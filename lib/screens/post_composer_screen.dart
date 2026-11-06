import 'package:flutter/material.dart';

import '../data/demo_media.dart';
import '../services/local_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/instagram_image.dart';

class PostComposerScreen extends StatefulWidget {
  const PostComposerScreen({super.key, required this.type, this.initialImage});

  final String type;
  final String? initialImage;

  @override
  State<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends State<PostComposerScreen> {
  late final TextEditingController _captionController;
  late final List<String> _images;
  late String _selectedImage;
  bool _sharing = false;

  String get _typeName => switch (widget.type) {
    'story' => 'Story',
    'reel' => 'Reel',
    _ => 'Post',
  };

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    _images = [
      DemoMedia.soccerPhoto(0),
      DemoMedia.soccerPhoto(2),
      DemoMedia.soccerPhoto(4),
      DemoMedia.photo(1),
      DemoMedia.photo(3),
      DemoMedia.photo(5),
      DemoMedia.soccerPhoto(6),
      DemoMedia.soccerPhoto(8),
      DemoMedia.photo(7),
      DemoMedia.photo(9),
      DemoMedia.soccerPhoto(10),
      DemoMedia.photo(11),
    ];
    _selectedImage = widget.initialImage ?? _images.first;
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.type == 'story' || widget.type == 'reel';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New $_typeName',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _sharing ? null : _share,
            child: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 26),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                InstagramAvatar(
                  url: DemoMedia.profileAvatarSmall,
                  size: 36,
                  showRing: false,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DemoMedia.profileUsername,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
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
                    const Text(
                      'Sharing to Instagram',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                const Spacer(),
                if (isVertical)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.type == 'reel' ? 'REEL' : 'STORY',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Stack(
            fit: StackFit.passthrough,
            children: [
              AspectRatio(
                aspectRatio: isVertical ? 0.8 : 1,
                child: InstagramImage(url: _selectedImage),
              ),
              if (isVertical)
                const Center(
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white,
                    size: 52,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 14)],
                  ),
                ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.crop_rotate_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: TextField(
              controller: _captionController,
              minLines: 2,
              maxLines: 5,
              maxLength: 2200,
              decoration: const InputDecoration(
                hintText: 'Write a caption…',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Divider(),
          _toolbar(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text('RECENT', style: AppTheme.sectionLabel),
                Spacer(),
                Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              final image = _images[index];
              final selected = image == _selectedImage;
              return GestureDetector(
                onTap: () => setState(() => _selectedImage = image),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InstagramImage(url: image),
                      if (selected)
                        Container(
                          color: Colors.black.withValues(alpha: 0.24),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _tool(Icons.location_on_outlined, 'Add location'),
          _tool(Icons.person_add_alt_1_outlined, 'Tag people'),
          _tool(Icons.music_note_rounded, 'Add audio'),
          _tool(Icons.accessibility_new_rounded, 'Accessibility'),
          _tool(Icons.tune_rounded, 'Advanced settings'),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String label) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(label),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.ink),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    LocalAppState.instance.publish(
      imageUrl: _selectedImage,
      caption: _captionController.text.trim(),
      type: widget.type,
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
