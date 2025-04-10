import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../exporter.dart';
import '../../../models/name_id.dart';

class ImageAttachment extends StatelessWidget {
  const ImageAttachment({
    super.key,
    required this.remote,
    required this.onDelete,
    required this.image,
  });

  final NameId image;

  final bool remote;
  final Function(NameId p1) onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(padding),
          child: Builder(builder: (context) {
            return OpenContainer(
                closedBuilder: (context, action) {
                  if (!remote) {
                    return Image.file(
                      File(image.secondary!),
                      fit: BoxFit.cover,
                    );
                  } else {
                    return CachedNetworkImage(
                      imageUrl: image.secondary!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Assets.pngs.brokenImage.image(
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
                openBuilder: (context, _) => Dismissible(
                      onUpdate: (details) => Navigator.maybePop(context),
                      direction: DismissDirection.down,
                      key: const Key("imageView"),
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(image.name),
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.black,
                          actions: [
                            if (remote)
                              IconButton(
                                color: Colors.white,
                                onPressed: () =>
                                    launchUrl(Uri.parse(image.secondary)),
                                icon: const Icon(
                                  Icons.download,
                                ),
                              ),
                            IconButton(
                              color: Colors.white,
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(
                                Icons.close,
                              ),
                            )
                          ],
                        ),
                        backgroundColor: Colors.black,
                        body: InteractiveViewer(
                          child: SizedBox(
                              width: SizeUtils.width,
                              child: (!remote)
                                  ? Image.file(
                                      File(image.secondary!),
                                      fit: BoxFit.contain,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: image.secondary!,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) =>
                                          Assets.pngs.brokenImage.image(
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                        ),
                      ),
                    ));
          }),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const OvalBorder(),
                onTap: () => onDelete(image),
                child: Container(
                  padding: const EdgeInsets.all(paddingSmall),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: padding * 1.5,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class AttachmentItem extends StatelessWidget {
  const AttachmentItem({
    super.key,
    required this.attachment,
    this.remote = false,
    required this.onDelete,
  });

  final NameId attachment;
  final bool remote;
  final Function(NameId) onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: padding,
      ),
      decoration: messageBorder.copyWith(
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: openAttachment,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingLarge,
              vertical: padding,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  CustomFileType.fromString(attachment.name).fileIcon,
                ),
                gap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        style: context.bodySmall,
                      ),
                      Text(
                        (attachment.name).split(".").last.toUpperCase(),
                        style: context.bodySmall.copyWith(
                          color: const Color(
                            0xff666666,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: () => onDelete(attachment),
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
                if (remote)
                  IconButton(
                    style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: openAttachment,
                    icon: const Icon(
                      Icons.file_download_outlined,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openAttachment() {
    if (remote) {
      launchUrl(
        Uri.parse(
          attachment.secondary,
        ),
      );
    } else {
      OpenFilex.open(attachment.secondary);
    }
  }
}

class AttachmentItems extends StatelessWidget {
  const AttachmentItems({
    super.key,
    this.attachments = const [],
    this.remote = false,
    required this.onDelete,
  });
  final List<NameId> attachments;
  final bool remote;
  final Function(NameId) onDelete;

  @override
  Widget build(BuildContext context) {
    final List<NameId> images = attachments
        .where(
          (e) => CustomFileType.isImage(e.name),
        )
        .toList();
    final List<NameId> files = attachments
        .where(
          (element) => !images.contains(element),
        )
        .toList();

    return Column(
      children: [
        if (images.isNotEmpty)
          GridView(
            padding: const EdgeInsets.only(
              top: paddingLarge,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: paddingLarge,
              crossAxisSpacing: paddingLarge,
            ),
            children: images
                .map(
                  (image) => ImageAttachment(
                      remote: remote, onDelete: onDelete, image: image),
                )
                .toList(),
          ),
        ListView(
          padding: const EdgeInsets.only(top: padding),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: files
              .map(
                (e) => AttachmentItem(
                  key: Key("logattachment${files.indexOf(e)}"),
                  attachment: e,
                  onDelete: onDelete,
                  remote: remote,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

enum CustomFileType {
  png,
  jpg,
  jpeg,
  heic,
  pdf,
  excel,
  zip,
  word;

  String get fileExtension {
    switch (this) {
      case CustomFileType.png:
        return "png";
      case CustomFileType.jpg:
        return "jpg";
      case CustomFileType.jpeg:
        return "jpeg";
      case CustomFileType.pdf:
        return "pdf";
      case CustomFileType.excel:
        return "exl";
      case CustomFileType.word:
        return "wrd";
      case CustomFileType.heic:
        return "heic";
      case CustomFileType.zip:
        return "zip";
    }
  }

  static CustomFileType fromString(String fileName) {
    return CustomFileType.values.firstWhereOrNull((item) =>
            fileName.split(".").last.toLowerCase() == item.fileExtension) ??
        CustomFileType.zip;
  }

  String get fileIcon {
    switch (this) {
      case CustomFileType.pdf:
        return Assets.svgs.pdfIcon;
      case CustomFileType.excel:
        return Assets.svgs.excelIcon;
      case CustomFileType.zip:
        return Assets.svgs.zipIcon;
      case CustomFileType.word:
        return Assets.svgs.wordIcon;
      default:
        return Assets.svgs.zipIcon;
    }
  }

  static bool isImage(String e) {
    final extension = e.split(".").last.toLowerCase();
    return imageTypes
        .map((element) => element.fileExtension)
        .contains(extension);
  }
}

List<CustomFileType> imageTypes = [
  CustomFileType.png,
  CustomFileType.jpeg,
  CustomFileType.jpg,
  CustomFileType.heic,
];
