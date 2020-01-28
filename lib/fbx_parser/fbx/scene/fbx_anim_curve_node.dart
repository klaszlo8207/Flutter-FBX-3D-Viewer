/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_scene.dart';

class FbxAnimCurveNode extends FbxObject {
  FbxAnimCurveNode(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'AnimCurveNode', element, scene);
}
