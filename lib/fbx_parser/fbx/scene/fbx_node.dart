/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import '../matrix_utils.dart';
import 'fbx_object.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';


class FbxNode extends FbxObject {
  FbxProperty translate;
  FbxProperty rotate;
  FbxProperty scale;
  FbxProperty visibility;
  Matrix4 transform;
  double evalTime;
  FbxNode parent;
  List<FbxNode> children = [];

  FbxNode(int id, String name, String type, FbxElement element, FbxScene scene)
    : super(id, name, type, element, scene) {
    translate = addProperty('Lcl Translation', Vector3(0.0, 0.0, 0.0));
    rotate = addProperty('Lcl Rotation', Vector3(0.0, 0.0, 0.0));
    scale = addProperty('Lcl Scaling', Vector3(1.0, 1.0, 1.0));
    visibility = addProperty('Visibility', 1);

    for (final c in element.children) {
      if (c.id == 'Properties70') {
        for (final p in c.children) {
          if (p.id == 'P') {
            if (p.properties[0] == 'Lcl Translation') {
              translate.value = Vector3(p.getDouble(4), p.getDouble(5),
                  p.getDouble(6));
            } else if (p.properties[0] == 'Lcl Rotation') {
              rotate.value = Vector3(p.getDouble(4), p.getDouble(5),
                  p.getDouble(6));
            } else if (p.properties[0] == 'Lcl Scaling') {
              scale.value = Vector3(p.getDouble(4), p.getDouble(5),
                  p.getDouble(6));
            } else if (p.properties[0] == 'Visibility') {
              visibility.value = p.getInt(4);
            }
          }
        }
      } else if (c.id == 'Properties60') {
        for (final p in c.children) {
          if (p.id == 'Property') {
            if (p.properties[0] == 'Lcl Translation') {
              translate.value = Vector3(p.getDouble(3), p.getDouble(4),
                  p.getDouble(5));
            } else if (p.properties[0] == 'Lcl Rotation') {
              rotate.value = Vector3(p.getDouble(3), p.getDouble(4),
                  p.getDouble(5));
            } else if (p.properties[0] == 'Lcl Scaling') {
              scale.value = Vector3(p.getDouble(3), p.getDouble(4),
                  p.getDouble(5));
            } else if (p.properties[0] == 'Visibility') {
              visibility.value = p.getInt(3);
            }
          }
        }
      }
    }

    resetLocalTransform();
  }

  @override
  void connectTo(FbxObject other) {
    if (other is FbxNode) {
      final node = other;
      children.add(node);
      node.parent = this;
    } else {
      super.connectTo(other);
    }
  }

  Matrix4 localTransform() => transform;

  Matrix4 globalTransform() {
    if (parent != null) {
      return (parent.globalTransform() * localTransform()) as Matrix4;
    }
    return localTransform();
  }

  Matrix4 evalLocalTransform() => scene.getNodeLocalTransform(this);

  Matrix4 evalGlobalTransform() => scene.getNodeGlobalTransform(this);

  void resetLocalTransform() {
    transform = Matrix4.identity();

    final t = translate.value as Vector3;
    final r = rotate.value as Vector3;
    final s = scale.value as Vector3;
    transform.translate(t.x, t.y, t.z);
    transform.rotateZ(radians(r.z));
    rotateY(transform, radians(r.y));
    transform.rotateX(radians(r.x));
    transform.scale(s.x, s.y, s.z);
  }
}
