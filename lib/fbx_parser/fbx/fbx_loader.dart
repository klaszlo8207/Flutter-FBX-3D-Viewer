/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'input_buffer.dart';
import 'fbx_element.dart';
import 'fbx_ascii_parser.dart';
import 'fbx_binary_parser.dart';
import 'fbx_parser.dart';
import 'scene/fbx_anim_curve.dart';
import 'scene/fbx_anim_curve_node.dart';
import 'scene/fbx_anim_layer.dart';
import 'scene/fbx_anim_stack.dart';
import 'scene/fbx_anim_key.dart';
import 'scene/fbx_camera.dart';
import 'scene/fbx_cluster.dart';
import 'scene/fbx_deformer.dart';
import 'scene/fbx_light.dart';
import 'scene/fbx_material.dart';
import 'scene/fbx_mesh.dart';
import 'scene/fbx_node.dart';
import 'scene/fbx_node_attribute.dart';
import 'scene/fbx_object.dart';
import 'scene/fbx_pose.dart';
import 'scene/fbx_scene.dart';
import 'scene/fbx_skeleton.dart';
import 'scene/fbx_skin_deformer.dart';
import 'scene/fbx_texture.dart';
import 'scene/fbx_video.dart';
import 'scene/fbx_global_settings.dart';

/// Decodes an FBX file into an [FbxScene] structure.
class FbxLoader {
  FbxScene load(List<int> bytes) {
    final input = InputBuffer(bytes);

    if (FbxBinaryParser.isValidFile(input)) {
      _parser = FbxBinaryParser(input);
    } else if (FbxAsciiParser.isValidFile(input)) {
      _parser = FbxAsciiParser(input);
    } else {
      return null;
    }

    final scene = FbxScene();

    var elem = _parser.nextElement();
    while (elem != null) {
      _loadRootElement(elem, scene);
      elem = _parser.nextElement();
    }

    _parser = null;

    return scene;
  }

  void _loadRootElement(FbxElement e, FbxScene scene) {
    //logger("-----PARSER _loadRootElement " + e.id);

    if (e.id == 'FBXHeaderExtension') {
      _loadHeaderExtension(e, scene);
    } else if (e.id == 'GlobalSettings') {
      final node = FbxGlobalSettings(e, scene);
      scene.globalSettings = node;
    } else if (e.id == 'Objects') {
      _loadObjects(e, scene);
    } else if (e.id == 'Connections') {
      _loadConnections(e, scene);
      _fixConnections(scene);
    } else if (e.id == 'Takes') {
      _loadTakes(e, scene);
    } else {
      //print('Unhandled Element ${e.id}');
    }
  }

  void _loadTakes(FbxElement e, FbxScene scene) {
    String currentTake;
    for (final c in e.children) {
      if (c.id == 'Current') {
        currentTake = c.properties[0] as String;
      } else if(c.id == 'Take') {
        // TODO store multiple takes
        if (c.properties[0] != currentTake) {
          continue;
        }

        _loadTake(c, scene);
      }
    }
  }

  // Older FBX versions store animation in 'Takes'
  void _loadTake(FbxElement e, FbxScene scene) {
    for (final c in e.children) {
      if (c.id == 'Model') {
        final name = c.properties[0] as String;

        final obj = scene.allObjects[name];
        if (obj == null) {
          print('Could not find object $name');
          continue;
        }

        for (final c2 in c.children) {
          if (c2.id == 'Channel') {
            _loadTakeChannel(c2, obj, scene);
          }
        }
      }
    }
  }

  void _loadTakeChannel(FbxElement c, FbxObject obj, FbxScene scene) {
    if (c.properties[0] == 'Transform') {
      for (final c2 in c.children) {
        if (c2.properties[0] == 'T') {
          final animNode = FbxAnimCurveNode(0, 'T', null, scene);
          obj.connectToProperty('Lcl Translation', animNode);
          for (final c3 in c2.children) {
            if (c3.id == 'Channel' && c3.properties[0] == 'X') {
              final animCurve = FbxAnimCurve(0, 'X', null, scene);
              animNode.connectToProperty('X', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Y') {
              final animCurve = FbxAnimCurve(0, 'Y', null, scene);
              animNode.connectToProperty('Y', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Z') {
              final animCurve = FbxAnimCurve(0, 'Z', null, scene);
              animNode.connectToProperty('Z', animCurve);
              _loadTakeCurve(c3, animCurve);
            }
          }
        } else if (c2.properties[0] == 'R') {
          final animNode = FbxAnimCurveNode(0, 'R', null, scene);
          obj.connectToProperty('Lcl Rotation', animNode);
          for (final c3 in c2.children) {
            if (c3.id == 'Channel' && c3.properties[0] == 'X') {
              final animCurve = FbxAnimCurve(0, 'X', null, scene);
              animNode.connectToProperty('X', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Y') {
              final animCurve = FbxAnimCurve(0, 'Y', null, scene);
              animNode.connectToProperty('Y', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Z') {
              final animCurve = FbxAnimCurve(0, 'Z', null, scene);
              animNode.connectToProperty('Z', animCurve);
              _loadTakeCurve(c3, animCurve);
            }
          }
        } else if (c2.properties[0] == 'S') {
          final animNode = FbxAnimCurveNode(0, 'S', null, scene);
          obj.connectToProperty('Lcl Scaling', animNode);
          for (final c3 in c2.children) {
            if (c3.id == 'Channel' && c3.properties[0] == 'X') {
              final animCurve = FbxAnimCurve(0, 'X', null, scene);
              animNode.connectToProperty('X', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Y') {
              final animCurve = FbxAnimCurve(0, 'Y', null, scene);
              animNode.connectToProperty('Y', animCurve);
              _loadTakeCurve(c3, animCurve);
            } else if (c3.id == 'Channel' && c3.properties[0] == 'Z') {
              final animCurve = FbxAnimCurve(0, 'Z', null, scene);
              animNode.connectToProperty('Z', animCurve);
              _loadTakeCurve(c3, animCurve);
            }
          }
        }
      }
    } else if (c.properties[0] == 'Visibility') {
      final animNode = FbxAnimCurveNode(0, 'Visibility', null, scene);
      obj.connectToProperty('Visibility', animNode);

      final animCurve = FbxAnimCurve(0, 'Visibility', null, scene);
      _loadTakeCurve(c, animCurve);
    }
  }

  void _loadTakeCurve(FbxElement e, FbxAnimCurve animCurve) {
    for (final c in e.children) {
      if (c.id == 'Default') {
        animCurve.defaultValue = c.getDouble(0);
      } else if (c.id == 'Key') {
        for (var pi = 0; pi < c.properties.length;) {
          final time = c.getInt(pi);
          final value = c.getDouble(pi + 1);

          animCurve.keys.add(FbxAnimKey(time, value,
              FbxAnimKey.INTERPOLATION_LINEAR));

          if ((pi + 2) >= c.properties.length) {
            break;
          }

          final type = c.properties[pi + 2].toString();
          var keyType = FbxAnimKey.INTERPOLATION_LINEAR;

          if (type == 'C') {
            keyType = FbxAnimKey.INTERPOLATION_CONSTANT;
            pi += 4;
          } else if (type == 'L') {
            keyType = FbxAnimKey.INTERPOLATION_LINEAR;
            pi += 3;
          } else if (type == 'true') {
            keyType = FbxAnimKey.INTERPOLATION_CUBIC;
            pi += 5;
          } else {
            keyType = FbxAnimKey.INTERPOLATION_CUBIC;
            pi += 7;
          }

          animCurve.keys.add(FbxAnimKey(time, value, keyType));
        }
      }
    }
  }

  /// Older versions of fbx connect deformers to the transform instead of
  /// the mesh.
  void _fixConnections(FbxScene scene) {
    for (final mesh in scene.meshes) {
      if (mesh.connectedFrom.isEmpty) {
        continue;
      }
      for (final cf in mesh.connectedFrom) {
        if (cf is FbxNode) {
          for (final df in cf.connectedTo) {
            if (df is FbxDeformer) {
              if (!mesh.connectedTo.contains(df)) {
                mesh.connectTo(df);
              }
            }
          }
        }
      }
    }
  }

  void _loadConnections(FbxElement e, FbxScene scene) {
    final SCENE = _parser.sceneName();

    for (final c in e.children) {
      if (c.id == 'C' || c.id == 'Connect') {
        final type = c.properties[0] as String;

        if (type == 'OO') {
          final src = c.properties[1].toString();
          final dst = c.properties[2].toString();

          final srcModel = scene.allObjects[src];
          if (srcModel == null) {
            print('COULD NOT FIND SRC NODE 1 : $src');
            continue;
          }

          if (dst == '0' || dst == SCENE) {
            scene.rootNodes.add(srcModel as FbxNode);
          } else {
            final dstModel = scene.allObjects[dst];
            if (dstModel != null) {
              dstModel.connectTo(srcModel);
            } else {
              print('COULD NOT FIND NODE 1 : $dst');
            }
          }
        } else if (type == 'OP') {
          final src = c.properties[1].toString();
          final dst = c.properties[2].toString();
          var attr = c.properties[3] as String;

          final srcModel = scene.allObjects[src];
          if (srcModel == null) {
            print('COULD NOT FIND SRC NODE 2 : $src $attr');
            continue;
          }

          final dstModel = scene.allObjects[dst];
          if (dstModel == null) {
            print('COULD NOT FIND NODE 2 : $dst ');
            continue;
          }
          else {
            attr = attr
                .split('|')
                .last;
            dstModel.connectToProperty(attr, srcModel);
          }
        }
      }
    }
  }

  void _loadObjects(FbxElement e, FbxScene scene) {
    //logger("-----PARSER _loadObjects " + e.id + " " + e.children.length.toString());

    for (final c in e.children) {
      //logger("-----PARSER _loadObjects children " + c.id);

      if (c.id == 'Model') {
        int id;
        String rawName;
        String type;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
          type = c.properties[2] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
          type = c.properties[1] as String;
        }

        //logger("-----PARSER prop len " + c.properties.length.toString());

        var name = _parser.getName(rawName);

        FbxObject node;

        if (type == 'Camera') {
          final camera = FbxCamera(id, name, c, scene);
          node = camera;
          scene.allObjects[rawName] = camera;
          scene.allObjects[name] = camera;
          scene.cameras.add(camera);
        } else if (type == 'Light') {
          final light = FbxLight(id, name, c, scene);
          node = light;
          scene.allObjects[rawName] = light;
          scene.allObjects[name] = light;
          scene.lights.add(light);
        } else if (type == 'Mesh') {
          // In older versions of Fbx, the mesh shape was combined with the
          // meshNode, rather than being a separate NodeAttribute; so we'll
          // split the nodes in that case.

          //logger("-----PARSER Mesh ");

          if (id == 0) {
            final meshNode = FbxNode(id, name, 'Transform', c, scene);
            scene.allObjects[rawName] = meshNode;
            scene.allObjects[name] = meshNode;

            final mesh = FbxMesh(id, c, scene);
            node = mesh;
            scene.meshes.add(mesh);
            meshNode.connectTo(mesh);
          } else {
            node = FbxNode(id, name, 'Transform', c, scene);
            scene.allObjects[rawName] = node;
            scene.allObjects[name] = node;
          }
        } else if (type == 'Limb' || type == 'LimbNode') {
          final limb = FbxSkeleton(id, name, type, c, scene);
          node = limb;
          scene.allObjects[rawName] = limb;
          scene.allObjects[name] = limb;
          scene.skeletonNodes.add(limb);
        } else {
          var tk = name.split(':');
          if (tk.length > 1) {
            name = tk[1];

            node = FbxNode(id, name, type, c, scene);
            scene.allObjects[rawName] = node;
            scene.allObjects[name] = node;

            node.reference = tk[0];
          } else {
            node = FbxNode(id, name, type, c, scene);
            scene.allObjects[rawName] = node;
            scene.allObjects[name] = node;
          }
        }

        if (id != 0) {
          scene.allObjects[id.toString()] = node;
        }
      } else if (c.id == 'Geometry') {
        final id = c.getInt(0);
        final type = c.properties[2] as String;

        if (type == 'Mesh' || type == 'Shape') {
          final mesh = FbxMesh(id, c, scene);

          if (id != 0) {
            scene.allObjects[id.toString()] = mesh;
          }
          scene.meshes.add(mesh);
        }
      } else if (c.id == 'Material') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final material = FbxMaterial(id, name, c, scene);
        scene.allObjects[rawName] = material;
        scene.allObjects[name] = material;
        if (id != 0) {
          scene.allObjects[id.toString()] = material;
        }
        scene.materials.add(material);
      } else if (c.id == 'AnimationStack') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final stack = FbxAnimStack(id, name, c, scene);
        if (id != 0) {
          scene.allObjects[id.toString()] = stack;
        }
        scene.allObjects[rawName] = stack;
        scene.allObjects[name] = stack;
        scene.animationStack.add(stack);
      } else if (c.id == 'AnimationLayer') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final layer = FbxAnimLayer(id, name, c, scene);
        if (id != 0) {
          scene.allObjects[id.toString()] = layer;
        }
        scene.allObjects[rawName] = layer;
        scene.allObjects[name] = layer;
      } else if (c.id == 'AnimationCurveNode') {
        int id;
        String rawName;
        //String type;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
          //type = c.properties[2];
        } else {
          id = 0;
          rawName = c.properties[0] as String;
          //type = c.properties[1];
        }

        final name = _parser.getName(rawName);

        final curve = FbxAnimCurveNode(id, name, c, scene);
        if (id != 0) {
          scene.allObjects[id.toString()] = curve;
        }
        scene.allObjects[rawName] = curve;
        scene.allObjects[name] = curve;
      } else if (c.id == 'Deformer') {
        int id;
        String rawName;
        String type;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
          type = c.properties[2] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
          type = c.properties[1] as String;
        }

        final name = _parser.getName(rawName);

        if (type == 'Skin') {
          final skin = FbxSkinDeformer(id, name, c, scene);
          scene.deformers.add(skin);
          scene.allObjects[rawName] = skin;
          scene.allObjects[name] = skin;
          if (id != 0) {
            scene.allObjects[id.toString()] = skin;
          }
        } else if (type == 'Cluster') {
          final cluster = FbxCluster(id, name, c, scene);
          scene.deformers.add(cluster);
          scene.allObjects[rawName] = cluster;
          scene.allObjects[name] = cluster;

          if (id != 0) {
            scene.allObjects[id.toString()] = cluster;
          }
        }
      } else if (c.id == 'Texture') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final texture = FbxTexture(id, name, c, scene);

        scene.textures.add(texture);
        scene.allObjects[rawName] = texture;
        scene.allObjects[name] = texture;
        if (id != 0) {
          scene.allObjects[id.toString()] = texture;
        }
      } else if (c.id == 'Folder') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final folder = FbxObject(id, name, c.id, c, scene);
        scene.allObjects[rawName] = folder;
        scene.allObjects[name] = folder;
        if (id != 0) {
          scene.allObjects[id.toString()] = folder;
        }
      } else if (c.id == 'Constraint') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final constraint = FbxObject(id, name, c.id, c, scene);
        scene.allObjects[rawName] = constraint;
        scene.allObjects[name] = constraint;
        if (id != 0) {
          scene.allObjects[id.toString()] = constraint;
        }
      } else if (c.id == 'AnimationCurve') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final animCurve = FbxAnimCurve(id, name, c, scene);
        scene.allObjects[rawName] = animCurve;
        scene.allObjects[name] = animCurve;
        if (id != 0) {
          scene.allObjects[id.toString()] = animCurve;
        }
      } else if (c.id == 'NodeAttribute') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final node = FbxNodeAttribute(id, name, c.id, c, scene);
        scene.allObjects[rawName] = node;
        scene.allObjects[name] = node;
        if (id != 0) {
          scene.allObjects[id.toString()] = node;
        }
      } else if (c.id == 'GlobalSettings') {
        var node = FbxGlobalSettings(c, scene);
        scene.globalSettings = node;
      } else if (c.id == 'SceneInfo') {
        var node = FbxObject(0, 'SceneInfo', c.id, c, scene);
        scene.sceneInfo = node;
      } else if (c.id == 'Pose') {
        var pose = FbxPose(c.properties[0].toString(),
            c.properties[1] as String, c, scene);
        scene.poses.add(pose);
      } else if (c.id == 'Video') {
        int id;
        String rawName;

        if (c.properties.length == 3) {
          id = c.getInt(0);
          rawName = c.properties[1] as String;
        } else {
          id = 0;
          rawName = c.properties[0] as String;
        }

        final name = _parser.getName(rawName);

        final video = FbxVideo(id, name, c.id, c, scene);

        scene.videos.add(video);
        scene.allObjects[rawName] = video;
        scene.allObjects[name] = video;
        if (id != 0) {
          scene.allObjects[id.toString()] = video;
        }
      } else {
        //print('UNKNOWN OBJECT ${c.id}');
      }
    }
  }


  void _loadHeaderExtension(FbxElement e, FbxScene data) {
    for (final c in e.children) {
      if (c.id == 'OtherFlags') {
        for (final c2 in c.children) {
          if (c2.properties.length == 1) {
            data.header[c2.id] = c2.properties[0];
          }
        }
      } else {
        if (c.properties.length == 1) {
          if (c.id == 'FBXVersion') {
            /*_fileVersion =*/ c.getInt(0);
          }

          data.header[c.id] = c.properties[0];
        }
      }
    }
  }

  //int _fileVersion = 0;
  FbxParser _parser;
}

