/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsLottiesGen {
  const $AssetsLottiesGen();

  /// File path: assets/lotties/invalid.json
  String get invalid => 'assets/lotties/invalid.json';

  /// File path: assets/lotties/network_connection.json
  String get networkConnection => 'assets/lotties/network_connection.json';

  /// File path: assets/lotties/offer_applied.json
  String get offerApplied => 'assets/lotties/offer_applied.json';

  /// File path: assets/lotties/payment-failed.json
  String get paymentFailed => 'assets/lotties/payment-failed.json';

  /// File path: assets/lotties/payment-success.json
  String get paymentSuccess => 'assets/lotties/payment-success.json';

  /// File path: assets/lotties/swipe.json
  String get swipe => 'assets/lotties/swipe.json';

  /// File path: assets/lotties/update.json
  String get update => 'assets/lotties/update.json';

  /// File path: assets/lotties/warning.json
  String get warning => 'assets/lotties/warning.json';

  /// List of all assets
  List<String> get values => [
        invalid,
        networkConnection,
        offerApplied,
        paymentFailed,
        paymentSuccess,
        swipe,
        update,
        warning
      ];
}

class $AssetsPngsGen {
  const $AssetsPngsGen();

  /// File path: assets/pngs/dummy_profile.jpeg
  AssetGenImage get dummyProfile =>
      const AssetGenImage('assets/pngs/dummy_profile.jpeg');

  /// List of all assets
  List<AssetGenImage> get values => [dummyProfile];
}

class $AssetsSvgsGen {
  const $AssetsSvgsGen();

  /// File path: assets/svgs/icons8-google.svg
  String get icons8Google => 'assets/svgs/icons8-google.svg';

  /// File path: assets/svgs/retry.svg
  String get retry => 'assets/svgs/retry.svg';

  /// File path: assets/svgs/study.svg
  String get study => 'assets/svgs/study.svg';

  /// List of all assets
  List<String> get values => [icons8Google, retry, study];
}

class Assets {
  Assets._();

  static const $AssetsLottiesGen lotties = $AssetsLottiesGen();
  static const $AssetsPngsGen pngs = $AssetsPngsGen();
  static const $AssetsSvgsGen svgs = $AssetsSvgsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
