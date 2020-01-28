/// Copyright (C) 2015 Brendan Duncan. All rights reserved.

enum FbxReferenceMode {
  /// This indicates that the mapping information for the n'th element is found
  /// in the n'th place of FbxLayerElementTemplate.directArray.
  Direct,
  /// This symbol is kept for backward compatibility with FBX v5.0 files.
  /// In FBX v6.0 and higher, this symbol is replaced with eIndexToDirect.
  Index,
  /// This indicates that the FbxLayerElementTemplate.indexArray contains, for
  /// the n'th element, an index in the FbxLayerElementTemplate.directArray
  /// array of mapping elements. IndexToDirect is usually useful for storing
  /// ByPolygonVertex mapping mode elements coordinates. Since the same
  /// coordinates are usually repeated many times, this saves spaces by storing
  /// the coordinate only one time and then referring to them with an index.
  /// Materials and Textures are also referenced with this mode and the actual
  /// Material/Texture can be accessed via the FbxLayerElementTemplate.directArray
  IndexToDirect
}


FbxReferenceMode stringToReferenceMode(String id) {
  if (id == 'Direct') {
    return FbxReferenceMode.Direct;
  } else if (id == 'Index') {
    return FbxReferenceMode.Index;
  } else if (id == 'IndexToDirect') {
    return FbxReferenceMode.IndexToDirect;
  }

  return FbxReferenceMode.Direct;
}
