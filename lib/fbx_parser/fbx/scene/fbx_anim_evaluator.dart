/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../matrix_utils.dart';
import 'fbx_anim_curve.dart';
import 'fbx_anim_curve_node.dart';
import 'fbx_node.dart';
import 'fbx_object.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';

class FbxAnimEvaluator extends FbxObject {
  FbxAnimEvaluator(FbxScene scene)
    : super(0, '', 'AnimEvaluator', null, scene);

  Matrix4 getNodeGlobalTransform(FbxNode node, double time) {
    var t = getNodeLocalTransform(node, time);

    if (node.parent != null) {
      final pt = getNodeGlobalTransform(node.parent, time);
      t = (pt * t) as Matrix4;
    }

    return t;
  }

  Matrix4 getNodeLocalTransform(FbxNode node, double time) {
    // Cache the evaluated transform
    if (node.evalTime == time) {
      return node.transform;
    }
    node.evalTime = time;

    final t = node.translate.value as Vector3;
    final r = node.rotate.value as Vector3;
    final s = node.scale.value as Vector3;
    var tx = t.x;
    var ty = t.y;
    var tz = t.z;
    var rx = r.x;
    var ry = r.y;
    var rz = r.z;
    var sx = s.x;
    var sy = s.y;
    var sz = s.z;

    if (node.translate.connectedFrom != null &&
        node.translate.connectedFrom is FbxAnimCurveNode) {
      final animNode = node.translate.connectedFrom as FbxAnimCurveNode;
      final ap = animNode.properties;

      if (ap.containsKey('X')) {
        tx = evalCurve(ap['X'].connectedFrom as FbxAnimCurve, time);
      }

      if (ap.containsKey('Y')) {
        ty = evalCurve(ap['Y'].connectedFrom as FbxAnimCurve, time);
      }

      if (ap.containsKey('Z')) {
        tz = evalCurve(ap['Z'].connectedFrom as FbxAnimCurve, time);
      }
    }


    if (node.rotate.connectedFrom != null
        && node.rotate.connectedFrom is FbxAnimCurveNode) {
      final animNode = node.rotate.connectedFrom as FbxAnimCurveNode;
      final ap = animNode.properties;

      if (ap.containsKey('X')) {
        rx = evalCurve(ap['X'].connectedFrom as FbxAnimCurve, time);
      }

      if (ap.containsKey('Y')) {
        ry = evalCurve(ap['Y'].connectedFrom as FbxAnimCurve, time);
      }

      if (ap.containsKey('Z')) {
        rz = evalCurve(ap['Z'].connectedFrom as FbxAnimCurve, time);
      }
    }


    if (node.scale.connectedFrom != null
        && node.scale.connectedFrom is FbxAnimCurveNode) {
      final animNode = node.scale.connectedFrom as FbxAnimCurveNode;
      final ap = animNode.properties;

      if (ap.containsKey('X')) {
        sx = evalCurve(ap['X'].connectedFrom as FbxAnimCurve, time);
      }

      if (ap.containsKey('Y')) {
        sy = evalCurve(ap['Y'].connectedFrom as FbxAnimCurve, time);
      }

      if (ap.containsKey('Z')) {
        sz = evalCurve(ap['Z'].connectedFrom as FbxAnimCurve, time);
      }
    }

    node.transform.setIdentity();
    node.transform.translate(tx, ty, tz);
    node.transform.rotateZ(radians(rz));
    rotateY(node.transform, radians(ry));
    node.transform.rotateX(radians(rx));
    node.transform.scale(sx, sy, sz);

    return node.transform;
  }


  double evalCurve(FbxAnimCurve curve, double frame) {
    if (curve.numKeys == 0) {
      if (curve.defaultValue != null) {
        return curve.defaultValue;
      }
      return 0.0;
    }

    if (frame < scene.timeToFrame(curve.keyTime(0))) {
      return curve.keyValue(0);
    }

    for (var i = 0, numKeys = curve.numKeys; i < numKeys; ++i) {
      final kf = scene.timeToFrame(curve.keyTime(i));
      if (frame == kf) {
        return curve.keyValue(i);
      }

      if (frame < kf) {
        if (i == 0) {
          return curve.keyValue(i);
        }

        final kf2 = scene.timeToFrame(curve.keyTime(i - 1));

        final u = (frame - kf2) / (kf - kf2);

        return ((1.0 - u) * curve.keyValue(i - 1)) +
               (u * curve.keyValue(i));
      }
    }

    return curve.keys.last.value;
  }
}
