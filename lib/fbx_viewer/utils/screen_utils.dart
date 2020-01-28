import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenUtils {
  ScreenUtils._();

  static double width = 1;
  static double height = 1;

  static init(BuildContext context) {
    var size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
  }
}