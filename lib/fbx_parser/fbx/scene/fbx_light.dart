/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_node_attribute.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';

class FbxLight extends FbxNodeAttribute {
  static const int SPOT = 0;
  static const int POINT = 1;
  static const int DIRECTIONAL = 2;

  static const int NO_DECAY = 0;
  static const int LINEAR_DECAY = 1;
  static const int QUADRATIC_DECAY = 2;
  static const int CUBIC_DECAY = 3;

  FbxProperty color;
  FbxProperty intensity;
  FbxProperty coneAngle;
  FbxProperty decay;
  FbxProperty lightType;

  FbxLight(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Light', element, scene) {
    color = addProperty('Color', Vector3(1.0, 1.0, 1.0));
    intensity = addProperty('Intensity', 1.0);
    coneAngle = addProperty('Cone angle', 1.0);
    decay = addProperty('Decay', NO_DECAY);
    lightType = addProperty('LightType', DIRECTIONAL);

    for (final c in element.children) {
      if (c.id == 'Properties60') {
        for (final p in c.children) {
          if (p.id == 'Property') {
            if (p.properties[0] == 'Color') {
              color.value = Vector3(p.getDouble(3), p.getDouble(4),
                                    p.getDouble(5));
            } else if (p.properties[0] == 'Intensity') {
              intensity.value = p.getDouble(3);
            } else if (p.properties[0] == 'Cone angle') {
              coneAngle.value = p.getDouble(3);
            } else if (p.properties[0] == 'LightType') {
              lightType.value = p.getInt(3);
            }
          }
        }
      }
    }
  }
}

