/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'dart:math';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

class FbxDisplayMesh {
  int numPoints;
  Float32List points;
  Float32List normals;
  Float32List uvs;
  Float32List colors;
  Uint16List indices;
  Float32List skinWeights;
  Float32List skinIndices;
  List<List<int>> pointMap;

  void generateSmoothNormals() {
    if (indices == null || points == null) {
      return;
    }

    // Compute normals
    normals = Float32List(points.length);
    for (var ti = 0; ti < indices.length; ti += 3) {
      final p1 = Vector3(points[indices[ti] * 3],
          points[indices[ti] * 3 + 1],
          points[indices[ti] * 3 + 2]);

      final p2 = Vector3(points[indices[ti + 1] * 3],
          points[indices[ti + 1] * 3 + 1],
          points[indices[ti + 1] * 3 + 2]);

      final p3 = Vector3(points[indices[ti + 2] * 3],
          points[indices[ti + 2] * 3 + 1],
          points[indices[ti + 2] * 3 + 2]);

      final N = (p2 - p1).cross(p3 - p1);

      normals[indices[ti] * 3] += N.x;
      normals[indices[ti] * 3 + 1] += N.y;
      normals[indices[ti] * 3 + 2] += N.z;

      normals[indices[ti + 1] * 3] += N.x;
      normals[indices[ti + 1] * 3 + 1] += N.y;
      normals[indices[ti + 1] * 3 + 2] += N.z;

      normals[indices[ti + 2] * 3] += N.x;
      normals[indices[ti + 2] * 3 + 1] += N.y;
      normals[indices[ti + 2] * 3 + 2] += N.z;
    }

    for (var ni = 0; ni < normals.length; ni += 3) {
      var l = normals[ni] * normals[ni] +
          normals[ni + 1] * normals[ni + 1] +
          normals[ni + 2] * normals[ni + 2];
      if (l == 0.0) {
        continue;
      }

      l = 1.0 / sqrt(l);

      normals[ni] *= l;
      normals[ni + 1] *= l;
      normals[ni + 2] *= l;
    }
  }
}
