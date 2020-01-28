import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

Float32List scalarValues(Float32List list, double v) {
  List<double> out = List<double>();
  for (int index = 0; index < list.length; index++) {
    out.add(list[index] * v);
  }
  return Float32List.fromList(out);
}

List<Vector2> listVector2FromFloat32List(Float32List list) {
  List<Vector2> vectors = List();
  for (int index = 0; index < list.length; index += 2) {
    var v = Vector2(
      list[index],
      list[index + 1],
    );
    vectors.add(v);
  }
  return vectors;
}

List<Vector3> listVector3FromUint16List(Uint16List list) {
  List<Vector3> vectors = List();
  for (int index = 0; index < list.length; index += 3) {
    var v = Vector3(
      list[index].toDouble(),
      list[index + 1].toDouble(),
      list[index + 2].toDouble(),
    );
    vectors.add(v);
  }
  return vectors;
}

List<Vector3> listVector3FromFloat32List(Float32List list) {
  List<Vector3> vectors = List();
  for (int index = 0; index < list.length; index += 3) {
    var v = Vector3(
      list[index],
      list[index + 1],
      list[index + 2],
    );
    vectors.add(v);
  }
  return vectors;
}

List<Vector4> listVector4FromFloat32List(Float32List list) {
  List<Vector4> vectors = List();
  for (int index = 0; index < list.length; index += 4) {
    var v = Vector4(
      list[index],
      list[index + 1],
      list[index + 2],
      list[index + 3],
    );
    vectors.add(v);
  }
  return vectors;
}

List<Matrix4> listMatrixFromFloat32List(Float32List skinPalette) {
  List<Matrix4> matrices = List();
  for (int index = 0; index < skinPalette.length; index += 16) {
    var m = Matrix4(
      skinPalette[index],
      skinPalette[index + 1],
      skinPalette[index + 2],
      skinPalette[index + 3],
      skinPalette[index + 4],
      skinPalette[index + 5],
      skinPalette[index + 6],
      skinPalette[index + 7],
      skinPalette[index + 8],
      skinPalette[index + 9],
      skinPalette[index + 10],
      skinPalette[index + 11],
      skinPalette[index + 12],
      skinPalette[index + 13],
      skinPalette[index + 14],
      skinPalette[index + 15],
    );
    matrices.add(m);
  }
  return matrices;
}

double getMultiplicationValue(double d) {
  String text = d.abs().toString();

  int integerPlaces = int.parse(text.split(".")[0]);
  String decimalPlaces = text.split(".")[1];

  if (integerPlaces > 1)
    return 1.0 / integerPlaces.toDouble();
  else {
    double count = 1;
    for (int i = 0; i < decimalPlaces.length; i++) {
      var char = decimalPlaces[i];
      if (char == '0')
        count *= 10;
      else
        break;
    }
    return count;
  }
}
