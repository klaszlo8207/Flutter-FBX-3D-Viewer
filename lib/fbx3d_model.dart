import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fbx/fbx.dart';
import 'package:fbx/fbx/fbx_loader.dart';
import 'package:fbx/fbx/scene/fbx_scene.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbx3d_viewer/fbx3d_object.dart';

import 'utils/logger.dart';

class Fbx3DModel {
  FbxScene scene;
  List<Fbx3DObject> objects = List();
  ui.ImageShader triangleShader;

  Fbx3DModel();

  _parseFbx(String cont) {
    logger("-----_parseFbx START");

    scene = FbxLoader().load(Uint8List.fromList(utf8.encode(cont)));

    for (FbxMesh mesh in scene.meshes) {
      FbxNode meshNode = mesh.getParentNode();
      if (meshNode == null) {
        continue;
      }

      mesh.generateDisplayMeshes();
      if (mesh.display.isEmpty) {
        continue;
      }

      Fbx3DObject object = Fbx3DObject(meshNode, mesh);
      object.setPoints(mesh.display[0].points);
      object.setNormals(mesh.display[0].normals);
      object.setIndices(mesh.display[0].indices);
      object.setUvs(mesh.display[0].uvs);
      object.setSkinning(mesh.display[0].skinWeights, mesh.display[0].skinIndices);

      object.transform = meshNode.evalGlobalTransform();

      objects.add(object);
    }

    logger("-----_parseFbx END");
  }

  parseFrom(BuildContext context, String contFbx) => _parseFbx(contFbx);
}
