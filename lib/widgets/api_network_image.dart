import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/helper/api_image_url.dart';

/// Изображение с API ([resolveApiImageUrl]). Работает на mobile и Web при CORS на статике API.
class ApiNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? cacheKey;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ApiNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.cacheKey,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveApiImageUrl(imageUrl);
    if (resolved == null) {
      return errorWidget ?? const SizedBox.shrink();
    }

    final image = Image.network(
      resolved,
      key: ValueKey(cacheKey ?? resolved),
      width: width,
      height: height,
      fit: fit,
      alignment: Alignment.center,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: false,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFAD03E2),
                  strokeWidth: 2,
                ),
              ),
            );
      },
      errorBuilder: (_, __, ___) =>
          errorWidget ??
          SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Icon(Icons.broken_image, color: context.groove.carouselDotInactive, size: 40),
            ),
          ),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
