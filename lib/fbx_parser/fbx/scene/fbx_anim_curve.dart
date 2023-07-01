import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_anim_key.dart';
import 'fbx_scene.dart';

class FbxAnimCurve extends FbxObject {
  late double defaultValue;
  late List<FbxAnimKey> keys = [];

  FbxAnimCurve(int id, String name, FbxElement? element, FbxScene scene)
      : super(id, name, 'AnimCurve', element!, scene) {

    if (element == null) {
      return;
    }

    //int version = 0;
    List<int>? keyTime;
    List<double>? keyValue;

    for (final c in element.children) {
      if (c.id == 'Default') {

      } else if (c.id == 'KeyVer') {
        //version = c.getInt(0);
      } else if (c.id == 'KeyTime') {
        keyTime = c.children.first?.properties as List<int>?;
      } else if (c.id == 'KeyValueFloat') {
        keyValue = c.children.first?.properties as List<double>?;
      } else if (c.id == 'KeyAttrFlags') {

      } else if (c.id == 'KeyAttrDataFloat') {

      } else if (c.id == 'KeyAttrRefCount') {

      }
    }

    if (keyTime != null && keyValue != null && keyTime.length == keyValue.length) {
      for (var i = 0; i < keyTime.length; ++i) {
        keys.add(FbxAnimKey(keyTime[i], keyValue[i], FbxAnimKey.INTERPOLATION_LINEAR));
      }
    }
  }


  int get numKeys => keys.length;

  int keyTime(int index) => keys[index].time;

  double keyValue(int index) => keys[index].value;
}