/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_node_attribute.dart';
import 'fbx_scene.dart';

class FbxNull extends FbxNodeAttribute {
  FbxNull(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Null', element, scene);
}
