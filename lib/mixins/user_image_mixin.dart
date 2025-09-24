import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../exporter.dart';
import '../../../services/file_picker_service.dart';

import '../widgets/upload_image_widget.dart';
import '../widgets/user_avatar.dart';

mixin UserImageMixin<T extends StatefulWidget> on State<T> {
  File? selectedProfileImage;
  File? selectedCoverImage;
  File? selectedCommercialLicenceImage;

  String? profileImageNetwork;
  String? coverImageNetwork;
  String? commercialLicenceImageNetwork;
  void showImagePicker({required String image, VoidCallback? onChanged}) async {
    final result = await FilePickerService.pickFileOrImage(
      aspectRatio: image == "cover" || image == "commercialLicence"
          ? CropAspectRatio(ratioX: 16.0, ratioY: 9.0)
          : CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    if (result == null) return;
    setState(() {
      if (image == "profile") {
        selectedProfileImage = result;
      } else if (image == "cover") {
        selectedCoverImage = result;
      } else if (image == "commercialLicence") {
        selectedCommercialLicenceImage = result;
      }
    });
    if (onChanged != null) {
      onChanged();
    }
  }

  Widget coverImage({VoidCallback? onChanged}) => UploadImageWidget(
    title: "Add Cover Photo",
    subtitle: "Select jpg, png, or jpeg",
    buttonText: "Browse",

    aspectRatio: 2,
    onTap: () => showImagePicker(image: "cover", onChanged: onChanged),
    removeImage: () => setState(() {
      selectedCoverImage = null;
      coverImageNetwork = null;
    }),
    image: selectedCoverImage,
    networkImage: coverImageNetwork,
  );

  Widget commercialLicenceImage({VoidCallback? onChanged}) => UploadImageWidget(
    title: "Upload Commercial Licence",
    subtitle: "Select jpg, png, or jpeg",
    buttonText: "Browse",

    aspectRatio: 2,
    onTap: () =>
        showImagePicker(image: "commercialLicence", onChanged: onChanged),
    removeImage: () => setState(() {
      selectedCommercialLicenceImage = null;
      commercialLicenceImageNetwork = null;
    }),
    image: selectedCommercialLicenceImage,
    networkImage: commercialLicenceImageNetwork,
  );

  Widget userImage({String? networkImage, VoidCallback? onChanged}) => Stack(
    children: [
      UserAvatar(
        size: 1.sw * .4,
        imageFile: selectedProfileImage,
        imageUrl:
            networkImage ??
            (selectedProfileImage == null ? profileImageNetwork : null) ??
            "",
      ),
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(1.sw * .5),
            onTap: () =>
                showImagePicker(image: "profile", onChanged: onChanged),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .3),
                  ),
                  padding: const EdgeInsets.all(paddingLarge),
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
