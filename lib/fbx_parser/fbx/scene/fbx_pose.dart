//import 'dart:typed_data';

/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_node.dart';
import 'fbx_object.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';

class FbxPose extends FbxObject {
  Map<FbxNode, Matrix4> data = {};
  String poseType = 'BindPose';

  FbxPose(String name, String type, FbxElement element, FbxScene scene)
    : super(0, name, type, element, scene) {
    for (final c in element.children) {
      if (c.id == 'Type') {
        poseType = c.getString(0);
      } else if (c.id == 'PoseNode') {
        Matrix4 matrix;
        String nodeName;

        for (final c2 in c.children) {
          if (c2.id == 'Node') {
            nodeName = c2.properties[0].toString();
          } else if (c2.id == 'Matrix') {
            var p = (c2.properties.length == 16) ? c2.properties
                    : (c2.children.length == 1 &&
                       c2.children[0].properties.length == 16) ? c2.children[0].properties
                    : (c2.properties.length == 1 && c2.properties[0] is List) ? c2.properties[0] as List
                    : null;
            if (p != null) {
              matrix = Matrix4.zero();
              for (var i = 0; i < 16; ++i) {
                matrix.storage[i] = toDouble(p[i]);
              }
            }
          }
        }

        if (matrix != null && nodeName != null) {
          final node = scene.allObjects[nodeName] as FbxNode;
          if (node != null) {
            data[node] = matrix;
          } else {
            print('Could not find pose node: $nodeName');
          }
        } else {
          print('Invalid PoseNode: $nodeName');
        }
      }
    }
  }

  Matrix4 getMatrix(FbxNode node) {
    if (!data.containsKey(node)) {
      return null;
    }
    return data[node];
  }
}
