/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_node.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';

class FbxSkeleton extends FbxNode {
  static const ROOT = 0;
  static const LIMB = 1;
  static const LIMB_NODE = 2;
  static const EFFECTOR = 3;

  FbxProperty skeletonType;

  FbxSkeleton(int id, String name, String type, FbxElement element,
              FbxScene scene)
    : super(id, name, type, element, scene) {
    skeletonType = setProperty('SkeletonType', LIMB);

    switch (type) {
      case 'Root':
        skeletonType.value = ROOT;
        break;
      case 'Limb':
        skeletonType.value = LIMB;
        break;
      case 'LimbNode':
        skeletonType.value = LIMB_NODE;
        break;
      case 'Effector':
        skeletonType.value = EFFECTOR;
        break;
    }
  }
}
