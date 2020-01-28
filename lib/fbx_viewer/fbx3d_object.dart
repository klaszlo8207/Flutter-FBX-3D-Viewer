import 'dart:typed_data';
import 'package:flutter_fbx3d_viewer/fbx_parser/fbx.dart';
import 'package:vector_math/vector_math.dart';

class Fbx3DObject {
  FbxNode node;
  FbxMesh mesh;
  Matrix4 transform;

  Float32List points;
  Float32List normals;
  Float32List uvs;
  Uint16List indices;

  Float32List skinPalette;
  Float32List skinWeights;
  Float32List skinIndices;

  Fbx3DObject(this.node, this.mesh);

  void update() {
    if (node != null) {
      transform = node.evalGlobalTransform();
      skinPalette = mesh.computeSkinPalette(skinPalette);
      setPoints(mesh.display[0].points);
    }
  }

  void setPoints(Float32List p) {
    if (points == null) {
      points = (p);
    }
  }

  void setNormals(Float32List n) {
    if (normals == null) {
      normals = (n);
    }
  }

  void setUvs(Float32List uv) {
    if (uv == null) {
      return;
    }

    if (uvs == null) {
      uvs = (uv);
    }
  }

  void setIndices(Uint16List i) {
    if (indices == null) {
      indices = (i);
    }
  }

  void setSkinning(Float32List weights, Float32List indices) {
    if (skinWeights == null) {
      skinWeights = (weights);
      skinIndices = (indices);
    }
  }
}
