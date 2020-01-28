/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_element.dart';

/// Base class for [FbxAsciiParser] and [FbxBinaryParser].
abstract class FbxParser {
  FbxElement nextElement();

  // Get the raw scene name, which is different depending on if it's an
  // ascii or binary file.
  String sceneName();

  // Node names are encoded with the type and need to be extracted.
  // The format of this encoding is different for binary and ascii;
  String getName(String rawName);
}
