// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../../../exporter.dart';
import '../../../services/file_picker_service.dart';
import '../widgets/attachment_viewer.dart';

extension FileExtension on File {
  AttachmentModel get attachmentMemmory {
    final bytes = readAsBytesSync();
    final data = base64Encode(bytes);
    final name = uri.pathSegments.last;
    final mimetype = lookupMimeType(path) ?? 'application/octet-stream';
    return AttachmentModel(
      name: name,
      mimetype: mimetype,
      data: data,
      type: AttachmentType.memmory,
    );
  }

  AttachmentModel get attachmentFile {
    final name = uri.pathSegments.last;
    final mimetype = lookupMimeType(path) ?? 'application/octet-stream';
    return AttachmentModel(
      name: name,
      mimetype: mimetype,
      data: path,
      type: AttachmentType.file,
    );
  }
}

enum AttachmentType {
  file,
  network,
  memmory;

  static AttachmentType fromValue(dynamic value) {
    return AttachmentType.values.firstWhere((element) => element.name == value,
        orElse: () => AttachmentType.network);
  }
}

class AttachmentModel {
  final String name;
  final String mimetype;
  final String data;
  final AttachmentType type;
  AttachmentModel({
    required this.name,
    required this.mimetype,
    required this.data,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'mimetype': mimetype,
      'data': data,
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      type: AttachmentType.fromValue(map["type"]),
      name: map['name'] as String,
      mimetype: map['mimetype'] as String,
      data: map['data'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttachmentModel.fromJson(String source) =>
      AttachmentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant AttachmentModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.mimetype == mimetype &&
        other.data == data &&
        other.type == type;
  }

  @override
  int get hashCode {
    return name.hashCode ^ mimetype.hashCode ^ data.hashCode ^ type.hashCode;
  }

  Uint8List? get bytes =>
      type != AttachmentType.memmory ? null : base64Decode(data);

  AttachmentModel get toMemmory {
    if (AttachmentType.file != type) {
      throw Exception("Must be file type");
    }
    return File(data).attachmentMemmory;
  }
}

mixin AttachmentMixin<T extends StatefulWidget> on State<T> {
  List<AttachmentModel> attachments = [];
  void deleteAttachements(AttachmentModel p1) {
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
    if (attachments.map((e) => e.name).contains(file.uri.pathSegments.last)) {
      return;
    }
    attachments.add(file.attachmentFile);
    setState(() {});
  }

  Widget attachmentWidget(
          {bool editable = true, Function(AttachmentModel)? onDelete}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gap,
          Visibility(
              visible: !(!editable && attachments.isEmpty),
              child: Text("Attachments")),
          gapSmall,
          AttachmentItems(
            onDelete: editable ? onDelete ?? deleteAttachements : null,
            attachments: attachments,
          ),
          Visibility(
            visible: editable,
            child: InkWell(
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
          ),
        ],
      );
}
