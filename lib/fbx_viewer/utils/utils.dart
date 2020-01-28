import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/screen_utils.dart';

import 'package:vector_math/vector_math.dart' as Math;

drawText(Canvas canvas, String s, Offset offset, {double fontSize = 18}) {
  final textStyle = TextStyle(
    color: Colors.white,
    fontSize: fontSize,
    shadows: [Shadow(blurRadius: 5, color: Colors.black, offset: const Offset(1, 1))],
  );
  final textSpan = TextSpan(text: s, style: textStyle);
  final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
  textPainter.layout(minWidth: 0);
  textPainter.paint(canvas, offset);
}

drawErrorText(Canvas canvas, String sHead, String sDesc) {
  drawText(canvas, sDesc, Offset(10, ScreenUtils.height / 2), fontSize: 12);
  drawText(canvas, sHead, Offset(10, ScreenUtils.height / 2 - 30), fontSize: 16);
}

Offset gen2DPointFrom3D(Math.Vector3 v) {
  final vn = Math.Vector3.copy(v);
  return Offset(vn.x, vn.y);
}

Color randomColor({double opacity}) => Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(opacity ?? 1.0);

int convertABGRtoARGB(int color) {
  int newColor = color;
  newColor = newColor & 0xFF00FF00;
  newColor = ((color & 0xFF) << 16) | newColor;
  newColor = ((color & 0x00FF0000) >> 16) | newColor;
  return newColor;
}

class ImageLoader {
  ImageLoader._();

  static Future<ui.Image> loadImage(BuildContext context, String path) async {
    final Completer<ui.Image> completer = new Completer();

    var fileImageUint8List;

    if (path.startsWith("assets/"))
      fileImageUint8List = (await rootBundle.load(path)).buffer.asUint8List();
    else
      fileImageUint8List = await File(path).readAsBytes();

    ui.decodeImageFromList(fileImageUint8List, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

