/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_anim_key.dart';
import 'fbx_scene.dart';

class FbxAnimCurve extends FbxObject {
  double defaultValue;
  List<FbxAnimKey> keys = [];

  FbxAnimCurve(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'AnimCurve', element, scene) {

    if (element == null) {
      return;
    }

    //int version = 0;
    List keyTime;
    List keyValue;

    for (final c in element.children) {
      if (c.id == 'Default') {

      } else if (c.id == 'KeyVer') {
        //version = c.getInt(0);
      } else if (c.id == 'KeyTime') {
        if (c.children.isEmpty) {
          continue;
        }
        keyTime = c.children[0].properties;
      } else if (c.id == 'KeyValueFloat') {
        if (c.children.isEmpty) {
          continue;
        }
        keyValue = c.children[0].properties;
      } else if (c.id == 'KeyAttrFlags') {

      } else if (c.id == 'KeyAttrDataFloat') {

      } else if (c.id == 'KeyAttrRefCount') {

      }
    }

    if (keyTime != null && keyValue != null) {
      if (keyTime.length == keyValue.length) {
        for (var i = 0; i < keyTime.length; ++i) {
          keys.add(FbxAnimKey(toInt(keyTime[i]),
                              toDouble(keyValue[i]),
                              FbxAnimKey.INTERPOLATION_LINEAR));
        }
      }
    }
  }


  int get numKeys => keys.length;

  int keyTime(int index) => keys[index].time;

  double keyValue(int index) => keys[index].value;
}
