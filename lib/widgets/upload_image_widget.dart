// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../exporter.dart';
import '../services/shared_preferences_services.dart';

class UploadImageWidget extends StatelessWidget {
  const UploadImageWidget({
    super.key,
    required this.onTap,
    required this.removeImage,
    this.aspectRatio = 317 / 124,
    this.image,
    this.networkImage,
  });

  final VoidCallback onTap;
  final VoidCallback removeImage;
  final double aspectRatio;
  final File? image;
  final String? networkImage;

  @override
  Widget build(BuildContext context) {
    final borderradius = BorderRadius.circular(paddingLarge);
    return InkWell(
      onTap: onTap,
      borderRadius: borderradius,
      child: DottedBorder(
        dashPattern: const [10, 5],
        color: Colors.grey,
        radius: const Radius.circular(paddingLarge),
        strokeCap: StrokeCap.butt,
        borderType: BorderType.RRect,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Builder(builder: (context) {
            if (image == null &&
                (networkImage == null || networkImage!.isEmpty)) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload),
                  Text(
                    "Upload an image",
                  ),
                  Text(
                    "Select jpg, png, or jpeg",
                  ),
                ],
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: borderradius,
                  child: Builder(builder: (context) {
                    if (image != null) {
                      return Image.file(
                        image!,
                        fit: BoxFit.cover,
                      );
                    }
                    return CachedNetworkImage(
                      imageUrl:
                          "${SharedPreferencesService.i.domainUrl}${networkImage!}",
                      fit: BoxFit.cover,
                    );
                  }),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(paddingLarge),
                    decoration: BoxDecoration(
                      borderRadius: borderradius,
                      color: Colors.black.withOpacity(
                        .1,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload),
                        Text(
                          "Change",
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: paddingLarge,
                    right: paddingLarge,
                    child: IconButton(
                      onPressed: removeImage,
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ))
              ],
            );
          }),
        ),
      ),
    );
  }
}
