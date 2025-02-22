import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/*
 image to bytes converter for map icons also sets size of the icon
 */
Future<Uint8List> assetToBytes(String path,{int width=100}) async {
  final byteData = await rootBundle.load(path);
  final bytes = byteData.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes,
      targetWidth: width
      //targetHeight: ...
  );
  final frame = await codec.getNextFrame();
  final newByteData = await frame.image.toByteData(
    format: ui.ImageByteFormat.png
  );
  return newByteData!.buffer.asUint8List();
}