/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';

class FbxAnimLayer extends FbxObject {
  static const int BLEND_ADDITIVE = 0;
  static const int BLEND_OVERRIDE = 1;
  static const int BLEND_OVERRIDE_PASSTHROUGH = 2;

  static const int ROTATION_BY_LAYER = 0;
  static const int ROTATION_BY_CHANNEL = 1;

  static const int SCALE_MULTIPLY = 0;
  static const int SCALE_ADDITIVE = 1;

  FbxProperty weight;
  FbxProperty mute;
  FbxProperty solo;
  FbxProperty lock;
  FbxProperty color;
  FbxProperty blendMode;
  FbxProperty rotationAccumulationMode;
  FbxProperty scaleAccumulationMode;

  FbxAnimLayer(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'AnimLayer', element, scene) {
    weight = addProperty('Weight', 100.0);
    mute = addProperty('Mute', false);
    solo = addProperty('Solo', false);
    lock = addProperty('Lock', false);
    color = addProperty('Color', Vector3(0.8, 0.8, 0.8));
    blendMode = addProperty('BlendMode', BLEND_ADDITIVE);
    rotationAccumulationMode = addProperty('RotationAccumulationMode', ROTATION_BY_LAYER);
    scaleAccumulationMode = addProperty('ScaleAccumulationMode', SCALE_MULTIPLY);

    for (final c in element.children) {
      if (c.id == 'Weight') {
        weight.value = c.getDouble(0);
      } else if (c.id == 'Mute') {
        weight.value = c.getInt(0) != 0;
      } else if (c.id == 'Solo') {
        solo.value = c.getInt(0) != 0;
      } else if (c.id == 'Lock') {
        lock.value = c.getInt(0) != 0;
      } else if (c.id == 'Color') {
        color.value = Vector3(c.getDouble(0), c.getDouble(1), c.getDouble(2));
      } else if (c.id == 'BlendMode') {
        blendMode.value = c.getInt(0);
      } else if (c.id == 'RotationAccumulationMode') {
        rotationAccumulationMode.value = c.getInt(0);
      } else if (c.id == 'ScaleAccumulationMode') {
        scaleAccumulationMode.value = c.getInt(0);
      }
    }
  }
}
