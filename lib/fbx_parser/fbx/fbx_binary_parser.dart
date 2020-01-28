/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_element.dart';
import 'fbx_parser.dart';
import 'input_buffer.dart';
import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Decodes a binary FBX file.
class FbxBinaryParser extends FbxParser {
  static const FILE_HEADER = 'Kaydara FBX Binary  \x00';

  static const int TYPE_BOOL = 67; // 'C'
  static const int TYPE_BYTE = 66; // 'B'
  static const int TYPE_INT16 = 89; // 'Y'
  static const int TYPE_INT32 = 73; // 'I'
  static const int TYPE_INT64 = 76; // 'L'
  static const int TYPE_FLOAT32 = 70; // 'F'
  static const int TYPE_FLOAT64 = 68; // 'D'
  static const int TYPE_ARRAY_BOOL = 99; // 'c'
  static const int TYPE_ARRAY_BYTE = 98; // 'b'
  static const int TYPE_ARRAY_INT16 = 121; // 'y'
  static const int TYPE_ARRAY_INT32 = 105; // 'i'
  static const int TYPE_ARRAY_INT64 = 108; // 'l'
  static const int TYPE_ARRAY_FLOAT32 = 102; // 'f'
  static const int TYPE_ARRAY_FLOAT64 = 100; // 'd'
  static const int TYPE_BYTES = 82; // 'R'
  static const int TYPE_STRING = 83; // 'S'
  static const String NAME_SEP = '\x00\x01';

  InputBuffer _input;

  static bool isValidFile(InputBuffer input) {
    final fp = input.offset;
    final header = input.readString(FILE_HEADER.length);
    input.offset = fp;

    if (header != FILE_HEADER) {
      return false;
    }

    return true;
  }

  FbxBinaryParser(InputBuffer input) {
    final fp = input.offset;
    final header = input.readString(FILE_HEADER.length);

    if (header != FILE_HEADER) {
      input.offset = fp;
      return;
    }

    _input = input;

    _input.skip(2); // \x1a\x00, not sure
    _input.skip(4); // file version
  }

  @override
  FbxElement nextElement() {
    if (_input == null) {
      return null;
    }

    final endOffset = _input.readUint32();
    final propCount = _input.readUint32();
    /*final propLength =*/ _input.readUint32();

    if (endOffset == 0) {
      return null;
    }

    var elemId = _input.readString(_input.readByte());

    final elem = FbxElement(elemId, propCount);

    for (var i = 0; i < propCount; ++i) {
      final s = _input.readByte();
      elem.properties[i] = _readData(_input, s);
    }

    const _BLOCK_SENTINEL_LENGTH = 13;

    if (_input.position < endOffset) {
      while (_input.position < (endOffset - _BLOCK_SENTINEL_LENGTH)) {
        elem.children.add(nextElement());
      }

      // Should be [0]*_BLOCK_SENTINEL_LENGTH
      _input.skip(_BLOCK_SENTINEL_LENGTH);
    }

    if (_input.position != endOffset) {
      throw Exception('scope length not reached, something is wrong');
    }

    return elem;
  }

  @override
  String sceneName() => 'Scene${NAME_SEP}Model';

  @override
  String getName(String rawName) =>
      rawName.substring(0, rawName.codeUnits.indexOf(0));

  dynamic _readData(InputBuffer input, int s) {
    switch (s) {
      case TYPE_BOOL:
        return input.readByte() != 0;
      case TYPE_BYTE:
        return input.readByte();
      case TYPE_INT16:
        return input.readInt16();
      case TYPE_INT32:
        return input.readInt32();
      case TYPE_INT64:
        return input.readInt64();
      case TYPE_FLOAT32:
        return input.readFloat32();
      case TYPE_FLOAT64:
        return input.readFloat64();
      case TYPE_BYTES:
        return input.readBytes(input.readUint32()).toUint8List();
      case TYPE_STRING:
        var st = input.readString(input.readUint32());
        return st;
      case TYPE_ARRAY_FLOAT32:
        return _readArray(input, s, 4);
      case TYPE_ARRAY_FLOAT64:
        return _readArray(input, s, 8);
      case TYPE_ARRAY_INT32:
        return _readArray(input, s, 4);
      case TYPE_ARRAY_INT64:
        return _readArray(input, s, 8);
      case TYPE_ARRAY_BYTE:
        return _readArray(input, s, 1);
      case TYPE_ARRAY_BOOL:
        return _readArray(input, s, 1);
    }
    return null;
  }

  dynamic _readArray(InputBuffer input, int s, int arrayStride) {
    const UNCOMPRESSED = 0;
    const ZLIB_COMPRESSED = 1;

    final length = input.readUint32();
    final encoding = input.readUint32();
    final compressedLength = input.readUint32();

    var bytes = input.readBytes(compressedLength);

    Uint8List data;
    if (encoding == ZLIB_COMPRESSED) {
      data = ZLibDecoder().decodeBytes(bytes.toUint8List()) as Uint8List;
    } else if (encoding == UNCOMPRESSED) {
      data = bytes.toUint8List();
    } else {
      throw Exception('Invalid Array Encoding $encoding');
    }

    if (length * arrayStride != data.length) {
      throw Exception('Invalid Array Data');
    }

    switch (s) {
      case TYPE_ARRAY_BYTE:
        return data;
      case TYPE_ARRAY_BOOL:
        return data;
      case TYPE_ARRAY_INT16:
        return data.buffer.asInt64List(0, length).toList(growable: false);
      case TYPE_ARRAY_INT32:
        return data.buffer.asInt32List(0, length).toList(growable: false);
      case TYPE_ARRAY_INT64:
        return data.buffer.asInt64List(0, length).toList(growable: false);
      case TYPE_ARRAY_FLOAT32:
        return data.buffer.asFloat32List(0, length).toList(growable: false);
      case TYPE_ARRAY_FLOAT64:
        var da = data.buffer.asFloat64List(0, length).toList(growable: false);
        return da;
    }

    return null;
  }
}
