/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'package:vector_math/vector_math.dart';
import 'dart:math';

Matrix4 inverseMat(Matrix4 m) {
  final i = Matrix4.copy(m);
  i.invert();
  return i;
}

void scaleMat(Matrix4 mat, double s) {
  for (var i = 0; i < 16; ++i) {
    mat.storage[i] *= s;
  }
}

// TODO vector_math Matrix4.rotateY has a bug. Replace this version with the
// vector_math version as soon as it gets fixed.
void rotateY(Matrix4 mat, double angle) {
  final cosAngle = cos(angle);
  final sinAngle = sin(angle);
  var t1 = mat.storage[0] * cosAngle - mat.storage[8] * sinAngle;
  var t2 = mat.storage[1] * cosAngle - mat.storage[9] * sinAngle;
  var t3 = mat.storage[2] * cosAngle - mat.storage[10] * sinAngle;
  var t4 = mat.storage[3] * cosAngle - mat.storage[11] * sinAngle;
  var t5 = mat.storage[0] * sinAngle + mat.storage[8] * cosAngle;
  var t6 = mat.storage[1] * sinAngle + mat.storage[9] * cosAngle;
  var t7 = mat.storage[2] * sinAngle + mat.storage[10] * cosAngle;
  var t8 = mat.storage[3] * sinAngle + mat.storage[11] * cosAngle;
  mat.storage[0] = t1;
  mat.storage[1] = t2;
  mat.storage[2] = t3;
  mat.storage[3] = t4;
  mat.storage[8] = t5;
  mat.storage[9] = t6;
  mat.storage[10] = t7;
  mat.storage[11] = t8;
}
