// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../exporter.dart';
import '../services/shared_preferences_services.dart';
import 'loading_button.dart';

class UploadImageWidget extends StatelessWidget {
  const UploadImageWidget({
    super.key,
    required this.onTap,
    this.removeImage,
    this.aspectRatio = 317 / 124,
    this.image,
    this.networkImage,
    this.title = "Upload an image",
    this.subtitle = "Select jpg, png, or jpeg",
    this.buttonText = "Browse",
  });

  final VoidCallback onTap;
  final VoidCallback? removeImage;
  final double aspectRatio;
  final File? image;
  final String? networkImage;

  final String title;
  final String subtitle;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final borderradius = BorderRadius.circular(paddingLarge);
    return InkWell(
      onTap: onTap,
      borderRadius: borderradius,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: [10, 5],
          strokeWidth: 1,
          radius: Radius.circular(16),
          color: Color(0xffD8D8DA),
        ),

        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Builder(
            builder: (context) {
              if (image == null &&
                  (networkImage == null || networkImage!.isEmpty)) {
                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xffD8D8DA),
                    borderRadius: BorderRadius.circular(paddingLarge),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: context.kanit40014),
                      Text(subtitle, style: context.kanit40008),
                      gap,
                      Center(
                        child: SizedBox(
                          height: 23 * 1.5,
                          width: 77 * 1.5,
                          child: LoadingButton(
                            aspectRatio: 23 / 77,
                            buttonLoading: false,
                            text: buttonText,
                            onPressed: onTap,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: borderradius,
                    child: Builder(
                      builder: (context) {
                        if (image != null) {
                          return Image.file(image!, fit: BoxFit.cover);
                        }
                        return CachedNetworkImage(
                          imageUrl:
                              "${SharedPreferencesService.i.domainUrl}${networkImage!}",
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(paddingLarge),
                      decoration: BoxDecoration(
                        borderRadius: borderradius,
                        color: Colors.black.withOpacity(.1),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.upload), Text("Change")],
                      ),
                    ),
                  ),
                  Positioned(
                    top: paddingLarge,
                    right: paddingLarge,
                    child: Visibility(
                      visible: removeImage != null,
                      child: IconButton(
                        onPressed: removeImage,
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
