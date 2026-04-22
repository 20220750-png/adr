import 'package:flutter/material.dart';

class KineticImage extends StatelessWidget {
  const KineticImage({
    super.key,
    required this.url,
    this.assetFallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.opacity,
  });

  final String url;
  final String? assetFallback;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    Widget img = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        if (assetFallback != null) {
          return Image.asset(
            assetFallback!,
            width: width,
            height: height,
            fit: fit,
            filterQuality: FilterQuality.medium,
          );
        }
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        );
      },
    );

    if (opacity != null) {
      img = Opacity(opacity: opacity!.clamp(0, 1), child: img);
    }

    return img;
  }
}

