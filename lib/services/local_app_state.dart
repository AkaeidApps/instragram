import 'package:flutter/foundation.dart';

import '../data/demo_media.dart';
import '../models/popular_result.dart';
import '../models/user.dart';

/// Local demo state shared by tabs so interactions remain visible while
/// navigating around the app. Replace with an authenticated API for production.
class LocalAppState extends ChangeNotifier {
  LocalAppState._();

  static final LocalAppState instance = LocalAppState._();

  final List<PopularResult> posts = [];
  final List<PopularResult> reels = [];
  final List<StoryEntry> stories = [];
  final Set<String> likedIds = {};
  final Set<String> savedIds = {};
  final Set<String> followedUserIds = {};
  final Map<String, List<String>> commentsByPost = {};
  final Map<String, List<String>> messagesByUser = {};

  bool isLiked(String id) => likedIds.contains(id);
  bool isSaved(String id) => savedIds.contains(id);
  bool isFollowing(String id) => followedUserIds.contains(id);

  void toggleLike(String id) {
    likedIds.contains(id) ? likedIds.remove(id) : likedIds.add(id);
    notifyListeners();
  }

  void toggleSaved(String id) {
    savedIds.contains(id) ? savedIds.remove(id) : savedIds.add(id);
    notifyListeners();
  }

  void toggleFollow(String userId) {
    followedUserIds.contains(userId)
        ? followedUserIds.remove(userId)
        : followedUserIds.add(userId);
    notifyListeners();
  }

  void addComment(String postId, String comment) {
    final value = comment.trim();
    if (value.isEmpty) return;
    commentsByPost.putIfAbsent(postId, () => []).insert(0, value);
    notifyListeners();
  }

  void sendMessage(String username, String message) {
    final value = message.trim();
    if (value.isEmpty) return;
    messagesByUser.putIfAbsent(username, () => []).add(value);
    notifyListeners();
  }

  PopularResult publish({
    required String imageUrl,
    required String caption,
    String type = 'post',
  }) {
    final id = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final post = PopularResult(
      id: id,
      position: 0,
      shortcode: id,
      link: 'https://www.instagram.com/',
      displayUrl: imageUrl,
      caption: caption,
      user: User(
        id: 'me',
        isVerified: true,
        profilePicUrl: DemoMedia.profileAvatarSmall,
        username: DemoMedia.profileUsername,
        link: 'https://www.instagram.com/neymarjr/',
      ),
      playCount: 0,
      videoVersions: type == 'reel' ? const ['local-demo-video'] : const [],
    );
    if (type == 'reel') {
      reels.insert(0, post);
    } else if (type == 'story') {
      stories.insert(
        0,
        StoryEntry(imageUrl: imageUrl, createdAt: DateTime.now()),
      );
    } else {
      posts.insert(0, post);
    }
    notifyListeners();
    return post;
  }
}

class StoryEntry {
  const StoryEntry({required this.imageUrl, required this.createdAt});

  final String imageUrl;
  final DateTime createdAt;
}
