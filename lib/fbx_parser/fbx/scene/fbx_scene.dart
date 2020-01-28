/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import 'fbx_frame_rate.dart';
import 'fbx_node.dart';
import 'fbx_object.dart';
import 'fbx_global_settings.dart';
import 'fbx_camera.dart';
import 'fbx_light.dart';
import 'fbx_deformer.dart';
import 'fbx_material.dart';
import 'fbx_anim_evaluator.dart';
import 'fbx_mesh.dart';
import 'fbx_anim_stack.dart';
import 'fbx_skeleton.dart';
import 'fbx_pose.dart';
import 'fbx_video.dart';
import 'fbx_texture.dart';
import 'package:vector_math/vector_math.dart';

/// Contains the description of a complete 3D scene.
class FbxScene extends FbxObject {
  final header = <String, dynamic>{};

  FbxGlobalSettings globalSettings;
  FbxObject sceneInfo;
  FbxAnimEvaluator evaluator;
  List<FbxCamera> cameras = [];
  List<FbxLight> lights = [];
  List<FbxMesh> meshes = [];
  List<FbxDeformer> deformers = [];
  List<FbxMaterial> materials = [];
  List<FbxAnimStack> animationStack = [];
  List<FbxSkeleton> skeletonNodes = [];
  List<FbxPose> poses = [];
  List<FbxVideo> videos = [];
  List<FbxTexture> textures = [];

  List<FbxNode> rootNodes = [];
  Map<String, FbxObject> allObjects = {};

  double startFrame = 1.0;
  double endFrame = 100.0;
  double currentFrame = 1.0;

  FbxScene()
    : super(0, '', 'Scene', null, null) {
    evaluator = FbxAnimEvaluator(this);
  }

  FbxPose getPose(int index) => index < poses.length ? poses[index] : null;

  Matrix4 getNodeLocalTransform(FbxNode node) =>
      evaluator.getNodeLocalTransform(node, currentFrame);

  Matrix4 getNodeGlobalTransform(FbxNode node) =>
        evaluator.getNodeGlobalTransform(node, currentFrame);

  int get timeMode {
    if (globalSettings != null) {
      return globalSettings.timeMode.value as int;
    }
    return FbxFrameRate.DEFAULT;
  }

  double get startTime => FbxFrameRate.frameToSeconds(startFrame, timeMode);

  double get endTime => FbxFrameRate.frameToSeconds(endFrame, timeMode);

  double timeToFrame(int timeValue) {
    return FbxFrameRate.timeToFrame(timeValue, timeMode);
  }

  double timeToSeconds(int timeValue) {
    return FbxFrameRate.timeToSeconds(timeValue, timeMode);
  }
}
