/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_deformer.dart';
import 'fbx_node.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';


class FbxSkinDeformer extends FbxDeformer {
  static const int RIGID = 0;
  static const int LINEAR = 1;
  static const int DUAL_QUATERNION = 2;
  static const int BLEND = 3;

  FbxProperty linkDeformAcuracy;
  FbxProperty skinningType;

  FbxSkinDeformer(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Skin', element, scene) {
    linkDeformAcuracy = addProperty('Link_DeformAcuracy', 50);
    skinningType = addProperty('SkinningType', RIGID);

    for (final c in element.children) {
      if (c.id == 'Link_DeformAcuracy') {
        linkDeformAcuracy.value = toInt(c.properties[0]);
      } else if (c.id == 'SkinningType') {
        if (c.properties[0] == 'Rigid') {
          skinningType.value = RIGID;
        } else if (c.properties[0] == 'Linear') {
          skinningType.value = LINEAR;
        } else if (c.properties[0] == 'DualQuaternion') {
          skinningType.value = DUAL_QUATERNION;
        } else if (c.properties[0] == 'Blend') {
          skinningType.value = BLEND;
        }
      }
    }
  }

  List<FbxNode> get clusters => connectedTo as List<FbxNode>;
}
