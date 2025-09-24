import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' hide ImageSource;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '../exporter.dart';
import '../main.dart';

enum ImageSource {
  /// Opens up the device camera, letting the user to take a new picture.
  camera,

  /// Opens the user's photo gallery.
  gallery,
  files;

  FileType get fileType {
    switch (this) {
      case ImageSource.camera:
        return FileType.image;
      case ImageSource.gallery:
        return FileType.image;
      case ImageSource.files:
        return FileType.any;
    }
  }
}

class FilePickerService {
  static Future<File?> pickFile({
    FileType fileType = FileType.image,
    List<String> allowedExtensions = const [],
  }) async {
    try {
      final result = (await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
      ));
      if (result == null) return null;
      return File(result.files.first.path!);
    } on PlatformException catch (e) {
      logError('Unsupported operation$e');
    } catch (e) {
      logError(e.toString());
    }
    return null;
  }

  static Future<File?> pickFromCamera() async {
    try {
      final result = await cameraPicker.pickImage(
        source: picker.ImageSource.camera,
      );
      if (result == null) return null;
      return File(result.path);
    } on PlatformException catch (e) {
      logError('Unsupported operation$e');
    } catch (e) {
      logError(e.toString());
    }
    return null;
  }

  static ImagePicker cameraPicker = ImagePicker();

  static Future<File?> pickFileOrImage({
    double? width,
    double? height,
    CropAspectRatio? aspectRatio,
    ImageSource imageSource = ImageSource.gallery,
    bool crop = true,
    FileType fileType = FileType.image,
  }) async {
    File? imageFile;
    switch (imageSource) {
      case ImageSource.camera:
        imageFile = await pickFromCamera();
        break;
      case ImageSource.files:
      case ImageSource.gallery:
        imageFile = await pickFile(fileType: fileType);
        break;
    }
    if (imageFile == null) return null;
    logInfo("Picked file ${imageFile.lengthSync()}");
    if (crop) {
      final croppedImagePath = await cropImage(
        imageFile,
        maxWidth: width,
        maxHeight: height,
        aspectRatio: aspectRatio,
      );
      return croppedImagePath;
    } else {
      return imageFile;
    }
  }

  static Future<File?> cropImage(
    File imageFile, {
    double? maxWidth,
    double? maxHeight,
    CropAspectRatio? aspectRatio,
  }) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      maxWidth: maxWidth?.toInt() ?? 720,
      maxHeight: maxHeight?.toInt() ?? 720,
      sourcePath: imageFile.path,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(aspectRatioLockEnabled: true),
      ],
    );
    if (croppedFile == null) return null;
    File croppd = File(croppedFile.path);
    logInfo("cropped  ${croppd.lengthSync()}");
    return croppd;
  }

  static Future<ImageSource?> showImageSourceBottomSheet() async {
    ImageSource? imageSource = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: navigatorKey.currentContext!,
      builder: (context) => const ImageSourceBottomSheet(),
    );
    return imageSource;
  }
}

class ImageSourceBottomSheet extends StatelessWidget {
  const ImageSourceBottomSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(padding),
          bottom: Radius.circular(padding),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: padding,
                vertical: paddingLarge,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white.withAlpha(200),
                      ),
                      // height: 230,
                      child: Column(
                        children: [
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: paddingLarge,
                              ),
                              child: Center(
                                child: Text(
                                  "Take Picture",
                                  style: context.bodyLarge.copyWith(
                                    color: const Color(0xff007AFF),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, ImageSource.camera);
                            },
                          ),
                          const Divider(height: 0, color: Color(0xffD8D8D8)),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: paddingLarge,
                              ),
                              child: Center(
                                child: Text(
                                  "Choose from Gallery",
                                  style: context.bodyLarge.copyWith(
                                    color: const Color(0xff007AFF),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, ImageSource.gallery);
                            },
                          ),
                          const Divider(height: 0, color: Color(0xffD8D8D8)),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: paddingLarge,
                              ),
                              child: Center(
                                child: Text(
                                  "Choose from Files",
                                  style: context.bodyLarge.copyWith(
                                    color: const Color(0xff007AFF),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, ImageSource.files);
                            },
                          ),
                        ],
                      ),
                    ),
                    gap,
                    Container(
                      //height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white.withAlpha(220),
                      ),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: paddingLarge,
                          ),
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "Cancel",
                              style: context.bodyLarge.copyWith(
                                color: const Color(0xff007AFF),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.maybePop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
