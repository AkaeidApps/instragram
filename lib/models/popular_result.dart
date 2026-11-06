import 'user.dart';

class PopularResult {
  final String id;
  final int position;
  final String shortcode;
  final String link;
  final String displayUrl;
  final String? caption;
  final User user;
  final int playCount;
  final List<String> videoVersions;

  PopularResult({
    required this.id,
    required this.position,
    required this.shortcode,
    required this.link,
    required this.displayUrl,
    this.caption,
    required this.user,
    required this.playCount,
    required this.videoVersions,
  });

  factory PopularResult.fromJson(Map<String, dynamic> json) {
    return PopularResult(
      id: json['id'] ?? '',
      position: json['position'] ?? 0,
      shortcode: json['shortcode'] ?? '',
      link: json['link'] ?? '',
      displayUrl: json['display_url'] ?? '',
      caption: json['caption'],
      user: User.fromJson(json['user'] ?? {}),
      playCount: json['play_count'] ?? 0,
      videoVersions: _parseVideoVersions(json['video_versions']),
    );
  }

  static List<String> _parseVideoVersions(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((entry) {
          if (entry is String) return entry;
          if (entry is Map<String, dynamic>) {
            return (entry['url'] ?? entry['src'] ?? '').toString();
          }
          return '';
        })
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  bool get isVideo => videoVersions.isNotEmpty;

  String? get videoUrl => isVideo ? videoVersions.first : null;
}
