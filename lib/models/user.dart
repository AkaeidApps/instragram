class User {
  final String id;
  final bool isVerified;
  final String profilePicUrl;
  final String username;
  final String link;

  User({
    required this.id,
    required this.isVerified,
    required this.profilePicUrl,
    required this.username,
    required this.link,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      isVerified: json['is_verified'] ?? false,
      profilePicUrl: json['profile_pic_url'] ?? '',
      username: json['username'] ?? '',
      link: json['link'] ?? '',
    );
  }
}
