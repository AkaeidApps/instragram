import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/demo_media.dart';
import '../theme/app_theme.dart';

/// Network image with skeleton loading, graceful error handling and a real
/// curated photo fallback (never an empty grey box).
class InstagramImage extends StatelessWidget {
  final String? url;
  final double? radius;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Color? backgroundColor;
  final bool avatarFallback;

  const InstagramImage({
    super.key,
    this.url,
    this.radius,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.backgroundColor,
    this.avatarFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = url?.trim();
    final Widget image;

    if (effectiveUrl == null || effectiveUrl.isEmpty) {
      image = _ImageFallback(
        seed: 'empty',
        width: width,
        height: height,
        fit: fit,
        backgroundColor: backgroundColor,
        avatarFallback: avatarFallback,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 220),
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
        placeholder: (context, _) =>
            placeholder ??
            _Shimmer(width: width, height: height, radius: radius),
        errorWidget: (context, _, _) =>
            placeholder ??
            _ImageFallback(
              seed: effectiveUrl,
              width: width,
              height: height,
              fit: fit,
              backgroundColor: backgroundColor,
              avatarFallback: avatarFallback,
            ),
      );
    }

    if (radius == null) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius!),
      child: image,
    );
  }
}

/// Shows a different real network photo when the original URL is stale, so
/// the UI keeps its photographic look instead of exposing a broken image.
class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.seed,
    this.width,
    this.height,
    required this.fit,
    this.backgroundColor,
    this.avatarFallback = false,
  });

  final String seed;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;
  final bool avatarFallback;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: avatarFallback
          ? DemoMedia.avatarFor(seed, size: 400)
          : DemoMedia.photoFor(seed, width: 1000),
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => _Shimmer(width: width, height: height),
      errorWidget: (context, _, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceStrong,
          gradient: backgroundColor == null ? AppGradients.brand : null,
        ),
        child: const Icon(
          Icons.image_outlined,
          color: Colors.white70,
          size: 22,
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({this.width, this.height, this.radius});

  final double? width;
  final double? height;
  final double? radius;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = _controller.value * 3 - 1.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.radius == null
                ? null
                : BorderRadius.circular(widget.radius!),
            gradient: LinearGradient(
              begin: Alignment(shift - 1, 0),
              end: Alignment(shift + 1, 0),
              colors: const [
                AppColors.surface,
                AppColors.surfaceStrong,
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Circular avatar with the signature Instagram gradient story ring.
class InstagramAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final bool isVerified;
  final String? username;
  final VoidCallback? onTap;
  final bool showRing;

  const InstagramAvatar({
    super.key,
    this.url,
    this.size = 40,
    this.isVerified = false,
    this.username,
    this.onTap,
    this.showRing = true,
  });

  @override
  Widget build(BuildContext context) {
    final ring = size + 6;
    final image = InstagramImage(
      url: url,
      radius: size / 2,
      width: size,
      height: size,
      fit: BoxFit.cover,
      avatarFallback: true,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ring,
        height: ring,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showRing)
              Container(
                width: ring,
                height: ring,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.story,
                ),
              )
            else
              Container(
                width: ring,
                height: ring,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.line,
                ),
              ),
            Container(
              width: size + 3,
              height: size + 3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            image,
            if (isVerified)
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.check, size: 8, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
