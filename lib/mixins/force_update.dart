import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../exporter.dart';
import '../../../widgets/loading_button.dart';
import 'dart:convert';

import '../widgets/common_sheet.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class VersionCheckResponseModel {
  final String url;
  final String message;
  final bool force;
  VersionCheckResponseModel({
    required this.url,
    required this.message,
    required this.force,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'message': message,
      'force': force,
    };
  }

  factory VersionCheckResponseModel.fromMap(Map<String, dynamic> map) {
    return VersionCheckResponseModel(
      url: map['url'] as String,
      message: map['message'] as String,
      force: map['force'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory VersionCheckResponseModel.fromJson(String source) =>
      VersionCheckResponseModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

mixin ForceUpdateMixin<T extends StatefulWidget> on State<T> {
  final db = FirebaseFirestore.instance;

  checkVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final platform = Platform.isAndroid ? "android" : "ios";

    final appVersion = int.parse(packageInfo.buildNumber);

    final docRef = db.collection(packageInfo.appName).doc(platform);

    docRef.get().then((value) async {
      final data = value.data();
      if (data == null) {
        await createDefaultData(docRef, {
          "current_version": appVersion,
          "minimum_version": appVersion,
          "url": "https://google.com",
          "message": "New version is available!",
        });
        return;
      }

      bool isUpdateAvailable = data["current_version"] > appVersion;

      if (!isUpdateAvailable) return;

      final versionModel = VersionCheckResponseModel(
          url: data["url"],
          message: data["message"],
          force: data["minimum_version"] > appVersion);
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => ForceUpdateBottomSheet(
          versionData: versionModel,
        ),
      );
    }).onError((error, stackTrace) {
      logError(error);
    });

    // DataRepository.i
    //     .checkVersion(UniversalArgument(id: int.parse(packageInfo.buildNumber)))
    //     .then((value) {
    //   if (value == null) return;
    //   showModalBottomSheet(
    //       isDismissible: false,
    //       enableDrag: false,
    //       context: context,
    //       builder: (context) => ForceUpdateBottomSheet(versionData: value));
    // }).onError((error, stackTrace) {
    //   showErrorMessage(error);
    // });
  }

  Future<bool> createDefaultData(
      DocumentReference<Map<String, dynamic>> docRef, data) async {
    await docRef.set(data);
    return true;
  }
}

class ForceUpdateBottomSheet extends StatelessWidget {
  const ForceUpdateBottomSheet({super.key, required this.versionData});

  final VersionCheckResponseModel versionData;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !versionData.force,
      child: CommonBottomSheet(
          title: "Update Avaialable",
          popButton: const SizedBox(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              gapXL,
              Lottie.asset(Assets.lotties.update, height: 100),
              Text(versionData.message),
              gapXL,
              Column(
                children: [
                  LoadingButton(
                      buttonLoading: false,
                      text: "Update Now",
                      onPressed: updateAction),
                  if (!versionData.force) gapLarge,
                  if (!versionData.force)
                    LoadingButton(
                        buttonLoading: false,
                        onPressed: () => Navigator.pop(context),
                        text: ("Cancel")),
                ],
              )
            ],
          )),
    );
  }

  void updateAction() async {
    final url = Uri.parse(versionData.url);
    if (!await canLaunchUrl(url)) return;
    launchUrl(url);
  }
}
