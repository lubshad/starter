import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../exporter.dart';
import '../../../services/file_picker_service.dart';
import '../../../services/size_utils.dart';
import '../widgets/upload_image_widget.dart';
import '../widgets/user_avatar.dart';


mixin UserImageMixin<T extends StatefulWidget> on State<T> {
  File? selectedProfileImage;
  File? selectedCoverImage;

  String? profileImageNetwork;
  String? coverImageNetwork;

  void showImagePicker({required String image, VoidCallback? onChanged}) async {
    final result = await FilePickerService().pickImage(
      aspectRatio: image == "cover"
          ? const CropAspectRatio(ratioX: 2, ratioY: 1)
          : const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (result == null) return;
    setState(() {
      if (image == "profile") {
        selectedProfileImage = result;
      } else if (image == "cover") {
        selectedCoverImage = result;
      }
    });
    if (onChanged != null) {
      onChanged();
    }
  }

  Widget uploadImageWidget({VoidCallback? onChanged}) => UploadImageWidget(
        aspectRatio: 2,
        onTap: () => showImagePicker(
          image: "cover",
          onChanged: onChanged,
        ),
        removeImage: () => setState(() {
          selectedCoverImage = null;
          coverImageNetwork = null;
        }),
        image: selectedCoverImage,
        networkImage: coverImageNetwork,
      );

  Widget userImage({String? networkImage, VoidCallback? onChanged}) => Stack(
        children: [
          UserAvatar(
            size: SizeUtils.width * .5,
            imageFile: selectedProfileImage,
            imageUrl: networkImage,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(SizeUtils.width * .5),
                onTap: () =>
                    showImagePicker(image: "profile", onChanged: onChanged),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.3),
                      ),
                      padding: const EdgeInsets.all(paddingLarge),
                      child: const Icon(
                        Icons.edit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
}
