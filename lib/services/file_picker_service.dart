import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../exporter.dart';
import '../main.dart';

class FilePickerService {
  Future<File?> pickFile(
      {FileType fileType = FileType.image,
      List<String> allowedExtensions = const []}) async {
    try {
      final result = (await FilePicker.platform
          .pickFiles(type: fileType, allowedExtensions: allowedExtensions));
      if (result == null) return null;
      return File(result.files.first.path!);
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    return null;
  }

  Future<File?> pickFromCamera() async {
    try {
      final result = await cameraPicker.pickImage(source: ImageSource.camera);
      if (result == null) return null;
      return File(result.path);
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    return null;
  }

  ImagePicker cameraPicker = ImagePicker();

  Future<File?> pickImage({
    double? width,
    double? height,
    CropAspectRatio? aspectRatio,
    ImageSource imageSource = ImageSource.gallery,
    bool crop = true,
  }) async {
    File? imageFile;
    switch (imageSource) {
      case ImageSource.camera:
        imageFile = await pickFromCamera();
        break;
      case ImageSource.gallery:
        imageFile = await pickFile();
        break;
    }
    if (imageFile == null) return null;
    logInfo("Picked file ${imageFile.lengthSync()}");
    if (crop) {
      final croppedImagePath = await cropImage(imageFile,
          maxWidth: width, maxHeight: height, aspectRatio: aspectRatio);
      return croppedImagePath;
    } else {
      return imageFile;
    }
  }

  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _logException(String message) {
    logInfo(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<File?> cropImage(File imageFile,
      {double? maxWidth,
      double? maxHeight,
      CropAspectRatio? aspectRatio}) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      maxWidth: maxWidth?.toInt() ?? 300,
      maxHeight: maxHeight?.toInt() ?? 300,
      sourcePath: imageFile.path,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );
    if (croppedFile == null) return null;
    File croppd = File(croppedFile.path);
    logInfo("cropped  ${croppd.lengthSync()}");
    return croppd;
  }

  Future<ImageSource?> showImageSourceBottomSheet() async {
    ImageSource? imageSource = await showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => const ImageSourceBottomSheet(),
    );
    return imageSource;
  }
}

class ImageSourceBottomSheet extends StatelessWidget {
  const ImageSourceBottomSheet({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Material(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(padding), bottom: Radius.circular(padding)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: padding,
                vertical: paddingLarge,
              ),
              child: SafeArea(
                top: false,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            iconSize: size.width * .1,
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.gallery),
                            icon: const Icon(Icons.image),
                          ),
                          const Text(
                            "Open Gallery",
                          )
                        ],
                      ),
                      const VerticalDivider(
                        width: 0,
                      ),
                      Column(
                        children: [
                          IconButton(
                            iconSize: size.width * .1,
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                          ),
                          const Text("Open Camer")
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
