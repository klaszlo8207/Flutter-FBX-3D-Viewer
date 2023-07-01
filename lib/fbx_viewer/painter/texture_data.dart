import 'dart:io';
import 'dart:ui' as UI;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/utils.dart';

import 'package:image/image.dart' as IMG;

class TextureData {
  IMG.Image? imageIMG;
  UI.Image? imageUI;
  int? width;
  int? height;

  Future<void> load(BuildContext context, String path, {int? resizeWidth}) async {
    late ByteData imageData;

    if (path.startsWith("assets/"))
      imageData = await rootBundle.load(path);
    else {
      final fileImg = File(path);
      if (await fileImg.exists()) {
        imageData = ByteData.view((await fileImg.readAsBytes()).buffer);
      }
    }

    final buffer = imageData.buffer;
    final imageInBytes = buffer.asUint8List(imageData.offsetInBytes, imageData.lengthInBytes);
    IMG.Image resized = IMG.copyResize(IMG.decodeImage(imageInBytes)!, width: resizeWidth);

    imageIMG = resized;
    width = imageIMG!.width;
    height = imageIMG!.height;

    imageUI = await ImageLoader.loadImage(context, path);
  }

  Color map(double tu, double tv) {
    if (imageIMG == null) {
      return Colors.white;
    }
    int u = ((tu * width!).toInt() % width!).abs();
    int v = ((tv * height!).toInt() % height!).abs();

    return Color(convertABGRtoARGB(imageIMG!.getPixel(u, v) as int));
  }
}