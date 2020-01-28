/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';

class FbxAnimStack extends FbxObject {
  FbxProperty description;
  FbxProperty localStart;
  FbxProperty localStop;
  FbxProperty referenceStart;
  FbxProperty referenceStop;

  FbxAnimStack(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'AnimStack', element, scene) {
    description = addProperty('Description', '');
    localStart = addProperty('LocalStart', 0);
    localStop = addProperty('LocalStop', 0);
    referenceStart = addProperty('ReferenceStart', 0);
    referenceStop = addProperty('ReferenceStop', 0);

    for (final c in element.children) {
      if (c.id == 'Properties70') {
        for (final c2 in c.children) {
          if (c2.properties[0] == 'Description') {
            description.value = c2.properties[4];
          } else if (c2.properties[0] == 'LocalStart') {
            localStart.value = c2.getInt(4);
          } else if (c2.properties[0] == 'LocalStop') {
            localStop.value = c2.getInt(4);
          } else if (c2.properties[0] == 'ReferenceStart') {
            referenceStart.value = c2.getInt(4);
          } else if (c2.properties[0] == 'ReferenceStop') {
            referenceStop.value = c2.getInt(4);
          }
        }
      }
    }
  }
}
