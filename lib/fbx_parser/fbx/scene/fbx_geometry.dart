/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_node_attribute.dart';
import 'fbx_scene.dart';

class FbxGeometry extends FbxNodeAttribute {
  FbxGeometry(int id, String name, String type, FbxElement element,
              FbxScene scene)
    : super(id, name, type, element, scene);
}

