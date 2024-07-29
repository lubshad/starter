// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../exporter.dart';

class UserAvatar extends StatelessWidget {
  UserAvatar({
    super.key,
    this.imageUrl,
    this.size = paddingXL,
    this.imageKey,
    this.errorImage,
    this.imageFile,
  });

  String? imageUrl;
  final double size;
  final String? imageKey;
  String? errorImage;
  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    errorImage ??= Assets.pngs.dummyProfile.keyName;
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        imageUrl!.contains("localhost")) {
      imageUrl = imageUrl!.replaceAll("localhost", appConfig.domain);
    }
    return SizedBox(
      height: size,
      width: size,
      child: ClipOval(
        child: Builder(builder: (context) {
          if (imageFile != null) {
            return Image.file(
              imageFile!,
              fit: BoxFit.cover,
            );
          }

          return CachedNetworkImage(
            cacheKey: imageKey,
            errorWidget: (context, url, error) => Image.asset(
              errorImage!,
              fit: BoxFit.cover,
            ),
            imageUrl: imageUrl ?? "",
            fit: BoxFit.cover,
          );
        }),
      ),
    );
  }
}
