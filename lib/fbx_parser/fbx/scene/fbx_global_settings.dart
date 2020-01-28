/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_frame_rate.dart';
import 'fbx_object.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';

class FbxGlobalSettings extends FbxObject {
  FbxProperty upAxis;
  FbxProperty upAxisSign;
  FbxProperty frontAxis;
  FbxProperty frontAxisSign;
  FbxProperty coordAxis;
  FbxProperty coordAxisSign;
  FbxProperty originalUpAxis;
  FbxProperty originalUpAxisSign;
  FbxProperty unitScaleFactor;
  FbxProperty originalUnitScaleFactor;
  FbxProperty ambientColor;
  FbxProperty defaultCamera;
  FbxProperty timeMode;
  FbxProperty timeProtocol;
  FbxProperty snapOnFrameMode;
  FbxProperty timeSpanStart;
  FbxProperty timeSpanStop;
  FbxProperty customFrameRate;

  FbxGlobalSettings(FbxElement element, FbxScene scene)
    : super(0, '', 'GlobalSettings', element, scene) {

    upAxis = addProperty('UpAxis', 1);
    upAxisSign = addProperty('UpAxisSign', 1);
    frontAxis = addProperty('FrontAxis', 2);
    frontAxisSign = addProperty('FrontAxisSign', 1);
    coordAxis = addProperty('CoordAxis', 0);
    coordAxisSign = addProperty('CoordAxisSign', 1);
    originalUpAxis = addProperty('OriginalUpAxis', 0);
    originalUpAxisSign = addProperty('OriginalUpAxisSign', 1);
    unitScaleFactor = addProperty('UnitScaleFactor', 1.0);
    originalUnitScaleFactor = addProperty('OriginalUnitScaleFactor', 1.0);
    ambientColor = addProperty('AmbientColor', Vector3(0.0, 0.0, 0.0));
    defaultCamera = addProperty('DefaultCamera', '');
    timeMode = addProperty('TimeMode', FbxFrameRate.DEFAULT);
    timeProtocol = addProperty('TimeProtocol', 0);
    snapOnFrameMode = addProperty('SnapOnFrameMode', 0);
    timeSpanStart = addProperty('TimeSpanStart', 0);
    timeSpanStop = addProperty('TimeSpanEnd', 0);
    customFrameRate = addProperty('CustomFrameRate', -1.0);

    for (final c in element.children) {
      if (c.id == 'Properties60' || c.id == 'Properties70') {
        final vi = c.id == 'Properties60' ? 3 : 4;
        for (final p in c.children) {
          if (p.properties[0] == 'UpAxis') {
            upAxis.value = p.getInt(vi);
          } else if (p.properties[0] == 'UpAxisSign') {
            upAxisSign.value = p.getInt(vi);
          } else if (p.properties[0] == 'FrontAxis') {
            frontAxis.value = p.getInt(vi);
          } else if (p.properties[0] == 'FrontAxisSign') {
            frontAxisSign.value = p.getInt(vi);
          } else if (p.properties[0] == 'CoordAxis') {
            coordAxis.value = p.getInt(vi);
          } else if (p.properties[0] == 'CoordAxisSign') {
            coordAxisSign.value = p.getInt(vi);
          } else if (p.properties[0] == 'OriginalUpAxis') {
            originalUpAxis.value = p.getInt(vi);
          } else if (p.properties[0] == 'OriginalUpAxisSign') {
            originalUpAxisSign.value = p.getInt(vi);
          } else if (p.properties[0] == 'UnitScaleFactor') {
            unitScaleFactor.value = p.getDouble(vi);
          } else if (p.properties[0] == 'OriginalUnitScaleFactor') {
            originalUnitScaleFactor.value = p.getDouble(vi);
          } else if (p.properties[0] == 'AmbientColor') {
            ambientColor.value = Vector3(p.getDouble(vi), p.getDouble(vi),
                                         p.getDouble(vi));
          } else if (p.properties[0] == 'DefaultCamera') {
            defaultCamera.value = p.getString(vi);
          } else if (p.properties[0] == 'TimeMode') {
            timeMode.value = p.getInt(vi);
          } else if (p.properties[0] == 'TimeProtocol') {
            timeProtocol.value = p.getInt(vi);
          } else if (p.properties[0] == 'SnapOnFrameMode') {
            snapOnFrameMode.value = p.getInt(vi);
          } else if (p.properties[0] == 'TimeSpanStart') {
            timeSpanStart.value = p.getInt(vi);
          } else if (p.properties[0] == 'TimeSpanStop') {
            timeSpanStop.value = p.getInt(vi);
          } else if (p.properties[0] == 'CustomFrameRate') {
            customFrameRate.value = p.getDouble(vi);
          }
        }
      }
    }

    scene.startFrame = FbxFrameRate.timeToFrame(timeSpanStart.value as int,
                                                timeMode.value as int);

    scene.endFrame = FbxFrameRate.timeToFrame(timeSpanStop.value as int,
                                              timeMode.value as int);

    scene.currentFrame = scene.startFrame;
  }
}
