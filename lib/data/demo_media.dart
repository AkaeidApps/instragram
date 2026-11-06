/// Curated network media used wherever the app needs a real image or video
/// (avatars, story rings, highlights, feed fallbacks and playable reels).
class DemoMedia {
  const DemoMedia._();

  /// Neymar Jr. — the profile that powers the signed-in experience.
  static const neymarAvatar =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/'
      'Neymar_%28cropped%29.jpg/960px-Neymar_%28cropped%29.jpg';

  static const neymarAvatarSmall =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/'
      'Neymar_%28cropped%29.jpg/500px-Neymar_%28cropped%29.jpg';

  static const _avatarIds = [
    'photo-1534528741775-53994a69daeb',
    'photo-1500648767791-00dcc994a43e',
    'photo-1494790108377-be9c29b29330',
    'photo-1507003211169-0a1dd7228f2d',
    'photo-1524504388940-b1c1722653e1',
    'photo-1517841905240-472988babdf9',
    'photo-1506794778202-cad84cf45f1d',
    'photo-1544005313-94ddf0286df2',
  ];

  static const _photoIds = [
    'photo-1470252649378-9c29740c9fa8',
    'photo-1501785888041-af3ef285b470',
    'photo-1518837695005-2083093ee35b',
    'photo-1490750967868-88aa4486c946',
    'photo-1500534623283-312aade485b7',
    'photo-1470770841072-f978cf4d019e',
    'photo-1519681393784-d120267933ba',
    'photo-1507525428034-b723cf961d3e',
    'photo-1464822759023-fed622ff2c3b',
    'photo-1493246507139-91e8fad9978e',
    'photo-1500530855697-b586d89ba3ee',
    'photo-1441974231531-c6227db76b6e',
  ];

  /// Football / stadium imagery for Neymar's profile grid.
  static const _soccerIds = [
    'photo-1579952363873-27f3bade9f55',
    'photo-1517466787929-bc90951d0974',
    'photo-1431324155629-1a6deb1dec8d',
    'photo-1526232761682-d26e03ac148e',
    'photo-1553778263-73a83bab9b0c',
    'photo-1574629810360-7efbbe195018',
    'photo-1489944440615-453fc2b6a9a9',
    'photo-1518604666860-9ed391f76460',
    'photo-1551958219-acbc608c6377',
    'photo-1522778119026-d647f0596c20',
    'photo-1540747913346-19e32dc3e97e',
    'photo-1518091043644-c1d4457512c6',
  ];

  /// Public, reliably hosted MP4s used to make the reels tab actually play.
  /// (Instagram CDN URLs in the bundled sample data expire, so the UI maps
  /// those to these stable demo clips.)
  static const _reelVideos = [
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://media.w3.org/2010/05/sintel/trailer.mp4',
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://media.w3.org/2010/05/bunny/trailer.mp4',
    'https://mdn.github.io/learning-area/html/multimedia-and-embedding/'
        'video-and-audio-content/rabbit320.mp4',
    'https://media.w3.org/2010/05/video/movie_300.mp4',
  ];

  static String _url(String id, {required int width, int? height}) {
    final heightPart = height == null ? '' : '&h=$height';
    return 'https://images.unsplash.com/$id'
        '?auto=format&fit=crop&w=$width$heightPart&q=80';
  }

  static String avatar(int index, {int size = 200}) =>
      _url(_avatarIds[index % _avatarIds.length], width: size, height: size);

  static String photo(int index, {int width = 900}) =>
      _url(_photoIds[index % _photoIds.length], width: width);

  static String soccerPhoto(int index, {int width = 900}) =>
      _url(_soccerIds[index % _soccerIds.length], width: width);

  static String photoFor(String seed, {int width = 900}) {
    final hash = seed.codeUnits.fold<int>(7, (value, unit) {
      return (value * 31 + unit) & 0x7fffffff;
    });
    return photo(hash, width: width);
  }

  static String soccerPhotoFor(String seed, {int width = 900}) {
    final hash = seed.codeUnits.fold<int>(13, (value, unit) {
      return (value * 31 + unit) & 0x7fffffff;
    });
    return soccerPhoto(hash, width: width);
  }

  static String avatarFor(String seed, {int size = 200}) {
    final hash = seed.codeUnits.fold<int>(11, (value, unit) {
      return (value * 37 + unit) & 0x7fffffff;
    });
    return avatar(hash, size: size);
  }

  static String highlight(int index, {int size = 200}) =>
      soccerPhoto(index + 2, width: size);

  static String reelVideo(int index) =>
      _reelVideos[index % _reelVideos.length];

  /// Returns a playable clip for any post, preferring the original URL when it
  /// is not an expired Instagram CDN link.
  static String? playableVideoFor({
    required String seed,
    required List<String> sources,
  }) {
    for (final source in sources) {
      if (source.startsWith('http') &&
          !source.contains('cdninstagram.com') &&
          !source.contains('local-demo-video')) {
        return source;
      }
    }
    final hash = seed.codeUnits.fold<int>(17, (value, unit) {
      return (value * 37 + unit) & 0x7fffffff;
    });
    return reelVideo(hash);
  }

  static String get profileAvatar => neymarAvatar;
  static String get profileAvatarSmall => neymarAvatarSmall;

  static const storyNames = [
    'Your story',
    'paulina.perez',
    'austin.life',
    'travel.diary',
    'daily.escape',
    'maria',
    'neymar',
  ];

  static const captions = [
    'A little reminder to slow down and enjoy the view ✨',
    'Golden hour in Austin never disappoints 🌅',
    'Weekend plans: nowhere, with good coffee ☕️',
    'Found this quiet corner of the city today.',
  ];

  static const soccerCaptions = [
    'Matchday mood ⚽️💫',
    'Training hard, dreaming bigger.',
    'Another night under the lights ✨',
    'Football is a feeling. 🇧🇷',
    'Keep the ball rolling. ⚽️',
    'Moments that stay forever.',
    'Recovery day, but never off the grind.',
    'For the love of the game.',
    'Ready for the next chapter.',
    'Smiles, sweat and stadium lights.',
    'Family first. Always. ❤️',
    'See you on the pitch.',
  ];

  static const reelCaptions = [
    'Golden hour magic 🌅 #reels',
    'A little slice of summer ☀️',
    'POV: your new favourite spot ✨',
    'Slow mornings, warm light ☕️',
    'Chasing sunsets, always.',
    'This sound + this view = perfect.',
    'Weekend energy, unlocked.',
    'Save this one for later 🔖',
  ];

  static const profileName = 'Neymar Jr';
  static const profileUsername = 'neymarjr';
  static const profileBio =
      'Footballer • @alhilal 🇧🇷⚽️\n'
      'Founder @institutoneymar\n'
      'Dream big. Work hard. Stay humble.';
  static const profileLink = 'neymarjr.com';
}
