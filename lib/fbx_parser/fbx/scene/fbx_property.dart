/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_object.dart';

class FbxProperty {
  dynamic value;
  FbxObject connectedFrom;

  FbxProperty(this.value);

  @override
  String toString() {
    if (connectedFrom != null) {
      return '${value} <--- ${connectedFrom.name}<${connectedFrom.type}>';
    }
    return value.toString();
  }
}
