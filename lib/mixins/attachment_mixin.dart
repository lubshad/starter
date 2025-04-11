import 'package:flutter/material.dart';

import '../../exporter.dart';
import '../../models/name_id.dart';
import '../../services/file_picker_service.dart';
import '../widgets/attachment_viewer.dart';

mixin AttachmentMixin<T extends StatefulWidget> on State<T> {
  List<NameId> attachments = [];
  deleteAttachements(NameId p1) {
    attachments.remove(p1);
    setState(() {});
  }

  void addAttachment() async {
    final source = await FilePickerService.showImageSourceBottomSheet();
    if (source == null) return;
    final file = await FilePickerService.pickFileOrImage(
      fileType: source.fileType,
      crop: false,
      imageSource: source,
    );
    if (file == null) return;
    if (attachments.map((e) => e.id).contains(file.path)) return;
    attachments.add(NameId(
      id: file.path,
      name: file.path.split("/").last,
      //secondary true means local file path.. else remote url
      secondary: true,
    ));
    setState(() {});
  }

  Widget get attachmentWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gap,
          Text("Attachments"),
          gapSmall,
          AttachmentItems(
            onDelete: deleteAttachements,
            attachments: attachments,
          ),
          InkWell(
            onTap: addAttachment,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: paddingSmall, horizontal: paddingLarge),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Color(0xffD93052))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attachment),
                  Text("Attach File"),
                ],
              ),
            ),
          ),
        ],
      );
}
