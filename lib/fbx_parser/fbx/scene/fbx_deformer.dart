/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_scene.dart';

class FbxDeformer extends FbxObject {
  FbxDeformer(int id, String name, String type, FbxElement element,
              FbxScene scene)
    : super(id, name, type, element, scene);
}
