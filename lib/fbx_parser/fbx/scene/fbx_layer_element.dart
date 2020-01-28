/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_mapping_mode.dart';
import 'fbx_reference_mode.dart';

class FbxLayerElement<T> {
  FbxMappingMode mappingMode = FbxMappingMode.None;
  FbxReferenceMode referenceMode = FbxReferenceMode.Direct;
  List<int> indexArray;
  List<T> data;

  int get length => data.length;

  T operator[](int index) => data[index];

  operator[]=(int index, T v) => data[index] = v;
}
