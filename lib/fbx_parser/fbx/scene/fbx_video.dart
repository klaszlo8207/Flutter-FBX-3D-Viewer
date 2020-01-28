/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_scene.dart';

class FbxVideo extends FbxObject {
  String filename;
  int useMipMap;

  FbxVideo(int id, String name, String type, FbxElement element, FbxScene scene)
    : super(id, name, type, element, scene) {
    for (final c in element.children) {
      if (c.id == 'UseMipMap') {
        useMipMap = c.getInt(0);
      } else if (c.id == 'Filename') {
        filename = c.getString(0);
      }
    }
  }
}
