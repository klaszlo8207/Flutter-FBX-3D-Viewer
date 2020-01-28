/// Copyright (C) 2015 Brendan Duncan. All rights reserved.

enum FbxMappingMode {
  /// The mapping is undetermined.
  None,
  /// There will be one mapping coordinate for each surface control point/vertex.
  ByControlPoint,
  /// There will be one mapping coordinate for each vertex, for every polygon
  /// of which it is a part. This means that a vertex will have as many mapping
  /// coordinates as polygons of which it is a part.
  ByPolygonVertex,
  /// There can be only one mapping coordinate for the whole polygon.
  ByPolygon,
  /// There will be one mapping coordinate for each unique edge in the mesh.
  /// This is meant to be used with smoothing layer elements.
  ByEdge,
  /// There can be only one mapping coordinate for the whole surface.
  AllSame
}

FbxMappingMode stringToMappingMode(String id) {
  id = id.toLowerCase();
  if (id == 'bycontrolpoint' || id == 'byvertex' || id == 'byvertice') {
    return FbxMappingMode.ByControlPoint;
  } else if (id == 'bypolygonvertex') {
    return FbxMappingMode.ByPolygonVertex;
  } else if (id == 'bypolygon') {
    return FbxMappingMode.ByPolygon;
  } else if (id == 'byedge') {
    return FbxMappingMode.ByEdge;
  } else if (id == 'allsame') {
    return FbxMappingMode.AllSame;
  } else {
    print('Unhandled Mapping Mode: ${id}');
  }

  return FbxMappingMode.None;
}
