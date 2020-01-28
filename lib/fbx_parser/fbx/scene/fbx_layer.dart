/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_layer_element.dart';
import 'package:vector_math/vector_math.dart';

class FbxLayer {
  bool get hasNormals => _normals != null;

  FbxLayerElement<Vector3> get normals {
    _normals ??= FbxLayerElement<Vector3>();
    return _normals;
  }


  bool get hasBinormals => _binormals != null;

  FbxLayerElement<Vector3> get binormals {
    _binormals ??= FbxLayerElement<Vector3>();
    return _binormals;
  }


  bool get hasTangents => _tangents != null;

  FbxLayerElement<Vector3> get tangents {
    _tangents ??= FbxLayerElement<Vector3>();
    return _tangents;
  }


  bool get hasUvs => _uvs != null;

  FbxLayerElement<Vector2> get uvs {
    _uvs ??= FbxLayerElement<Vector2>();
    return _uvs;
  }


  bool get hasColors => _colors != null;

  FbxLayerElement<Vector4> get colors {
    _colors ??= FbxLayerElement<Vector4>();
    return _colors;
  }

  FbxLayerElement<Vector3> _normals;
  FbxLayerElement<Vector3> _binormals;
  FbxLayerElement<Vector3> _tangents;
  FbxLayerElement<Vector2> _uvs;
  FbxLayerElement<Vector4> _colors;
}
