/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_node.dart';
import 'fbx_scene.dart';

class FbxTexture extends FbxNode {
  String filename;

  FbxTexture(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Texture', element, scene) {
    for (final c in element.children) {
      if (c.id == 'FileName') {
        filename = c.getString(0);
      }
    }
  }
}

