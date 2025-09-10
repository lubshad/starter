// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../exporter.dart';

String mediaurl(String? url) {
  if (url?.startsWith("http") == true) return url ?? "";
  return Uri.parse(appConfig.domainOnly + (url ?? "")).toString();
}

class UserAvatar extends StatelessWidget {
  UserAvatar({
    super.key,
    this.imageUrl,
    this.size = paddingXL,
    this.imageKey,
    this.errorImage,
    this.imageFile,
    this.borderRadius,
    this.username = "",
    this.bytes,
    this.borderColor,
    this.bgColor,
    this.addMediaUrl = true,
  });

  String? imageUrl;
  final double size;
  final String? imageKey;
  String? errorImage;
  final File? imageFile;
  final double? borderRadius;
  final String username;
  final Uint8List? bytes;
  final Color? borderColor;
  final Color? bgColor;
  final bool addMediaUrl;
  @override
  Widget build(BuildContext context) {
    errorImage ??= Assets.pngs.personPlaceholder.keyName;
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        imageUrl!.contains("localhost")) {
      imageUrl = imageUrl!.replaceAll("localhost", appConfig.domain);
    }
    bool isBytes =
        imageUrl?.startsWith("b'") == true &&
            ((imageUrl)?.length ?? 0) > 1000 ||
        bytes != null && bytes!.length > 500;

    final child = Builder(
      builder: (context) {
        if (isBytes && (imageUrl != null || bytes != null)) {
          return Image.memory(
            bytes ?? base64toMemmoryImageMain(imageUrl)!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          );
        }
        if (imageFile != null) {
          return Image.file(imageFile!, fit: BoxFit.cover);
        }
        // i need to add a condition to check if imageUrl contains media url

        if (imageUrl == null || imageUrl == "" && username.isNotEmpty == true) {
          String shortName = username;
          if (username.isEmpty) {
            shortName = "";
          } else if (username.split(" ").length > 1 &&
              username.split(" ").last.isNotEmpty) {
            shortName = username.split(" ")[0].substring(0, 1);
            shortName += username.split(" ")[1].substring(0, 1);
          } else {
            shortName = username.substring(0, 2);
          }
          // print();
          return Center(
            child: Text(
              shortName.toUpperCase(),
              style: context.bodyLarge.copyWith(
                fontSize: (12 / paddingXL) * size,
              ),
            ),
          );
        }

        return CachedNetworkImage(
          cacheKey: imageKey,
          errorWidget: (context, url, error) =>
              Image.asset(errorImage!, fit: BoxFit.cover),
          imageUrl: addMediaUrl ? mediaurl(imageUrl) : imageUrl ?? "",
          fit: BoxFit.cover,
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
        shape: BoxShape.circle,
      ),
      height: size,
      width: size,
      child: Builder(
        builder: (context) {
          if (borderRadius != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius!),
              child: child,
            );
          }
          return ClipOval(child: child);
        },
      ),
    );
  }
}

String? imageConvertToBase64Main(Uint8List? imageData) {
  if (imageData == null) return null;
  return "b'${base64Encode(imageData)}'";
}

Uint8List? base64toMemmoryImageMain(String? imageUrl) {
  if (imageUrl == null) {
    return null;
  }
  return base64Decode(imageUrl.substring(2, imageUrl.length - 1));
}

// Convert image to Base64 in an isolate
Future<String?> imageConvertToBase64(Uint8List? imageData) async {
  if (imageData == null) return null;
  return await compute(_convertToBase64, imageData);
}

String _convertToBase64(Uint8List imageData) {
  return "b'${base64Encode(imageData)}'";
}

// Convert Base64 to Uint8List in an isolate
Future<Uint8List?> base64toMemoryImage(String? imageUrl) async {
  if (imageUrl == null) return null;
  return await compute(_convertFromBase64, imageUrl);
}

Uint8List? _convertFromBase64(String imageUrl) {
  return base64Decode(imageUrl.substring(2, imageUrl.length - 1));
}
