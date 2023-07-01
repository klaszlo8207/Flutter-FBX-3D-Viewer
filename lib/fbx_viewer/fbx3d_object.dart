import 'dart:typed_data';
import 'package:flutter_fbx3d_viewer_v2/fbx_parser/fbx.dart';
import 'package:vector_math/vector_math.dart';

class Fbx3DObject {
  FbxNode node;
  FbxMesh mesh;
  late Matrix4 transform;

  late Float32List points;
  late Float32List normals;
  late Float32List uvs;
  late Uint16List indices;

  late Float32List skinPalette;
  late Float32List skinWeights;
  late Float32List skinIndices;

  Fbx3DObject(this.node, this.mesh);

  void update() {
    transform = node.evalGlobalTransform();
    skinPalette = mesh.computeSkinPalette(skinPalette)!;
    setPoints(mesh.display[0].points!);
  }

  void setPoints(Float32List p) {
    points = p;
  }

  void setNormals(Float32List n) {
    normals = n;
  }

  void setUvs(Float32List uv) {
    if (uv != null) {
      uvs = uv;
    }
  }

  void setIndices(Uint16List i) {
    indices = i;
  }

  void setSkinning(Float32List weights, Float32List indices) {
    skinWeights = weights;
    skinIndices = indices;
  }
}