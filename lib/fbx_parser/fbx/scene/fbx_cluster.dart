/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_deformer.dart';
import 'fbx_node.dart';
import 'fbx_scene.dart';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

class FbxCluster extends FbxDeformer {
  static const int NORMALIZE = 0;
  static const int ADDITIVE = 1;
  static const int TOTAL_ONE = 2;

  Uint32List indexes;
  Float32List weights;
  Matrix4 transform;
  Matrix4 transformLink;
  int linkMode = NORMALIZE;

  FbxCluster(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Cluster', element, scene) {

    for (final c in element.children) {
      var p = ((c.properties.length == 1 && c.properties[0] is List)
          ? c.properties[0]
          : (c.children.length == 1)
          ? c.children[0].properties
          : c.properties) as List;

      if (c.id == 'Indexes') {
        indexes = Uint32List(p.length);
        for (var i = 0, len = p.length; i < len; ++i) {
          indexes[i] = toInt(p[i]);
        }
      } else if (c.id == 'Weights') {
        weights = Float32List(p.length);
        for (var i = 0, len = p.length; i < len; ++i) {
          weights[i] = toDouble(p[i]);
        }
      } else if (c.id == 'Transform') {
        transform = Matrix4.identity();
        for (var i = 0, len = p.length; i < len; ++i) {
          transform.storage[i] = toDouble(p[i]);
        }
      } else if (c.id == 'TransformLink') {
        transformLink = Matrix4.identity();
        for (var i = 0, len = p.length; i < len; ++i) {
          transformLink.storage[i] = toDouble(p[i]);
        }
      }
    }
  }

  FbxNode getLink() =>
      connectedTo.isNotEmpty ? connectedTo[0] as FbxNode : null;
}

