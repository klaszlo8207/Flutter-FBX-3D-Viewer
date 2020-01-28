library flutter_fbx3d_viewer;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/fbx3d_model.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/fbx3d_object.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/painter/globals.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/painter/texture_data.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/painter/vertices_painter.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/converter.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/logger.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/math_utils.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/screen_utils.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/utils.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/widgets/zoom_gesture_detector.dart';
import 'package:vector_math/vector_math.dart' as Math;

import 'fbx3d_viewer.dart';

/// Created by Kozári László 2020.01.16
/// This is a simple non textured Fbx animated 3d file viewer.
///

class Fbx3DViewer extends StatefulWidget {
  final Size size;
  final String fbxPath;
  final bool showInfo;
  bool showWireframe;
  final Color wireframeColor;
  Math.Vector3 initialAngles;
  double initialZoom;
  final double animationSpeed;
  final Fbx3DViewerController fbx3DViewerController;
  int panDistanceToActivate = 10;
  final Function(double) onZoomChangeListener;
  final Function(Math.Vector3) onRotationChangeListener;
  final void Function(double dx) onHorizontalDragUpdate;
  final void Function(double dy) onVerticalDragUpdate;
  final int refreshMilliseconds;
  final int endFrame;
  Color color;
  final String texturePath;
  Math.Vector3 lightPosition;
  Color lightColor;
  final bool showWireFrame;
  final Color backgroundColor;
  final bool showGrids;
  final Color gridsColor;
  final int gridsMaxTile;
  final double gridsTileSize;

  currentState() => fbx3DViewerController.state;

  Fbx3DViewer({
    @required this.size,
    @required this.fbxPath,
    @required this.lightPosition,
    @required this.initialZoom,
    @required this.animationSpeed,
    @required this.fbx3DViewerController,
    @required this.refreshMilliseconds,
    @required this.endFrame,
    this.texturePath,
    this.backgroundColor = const Color(0xff353535),
    this.showInfo = false,
    this.showWireframe = false,
    this.wireframeColor = Colors.black,
    this.initialAngles,
    this.panDistanceToActivate = 10,
    this.onZoomChangeListener,
    this.onRotationChangeListener,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    this.color = Colors.white,
    this.lightColor = Colors.white,
    this.showWireFrame = true,
    this.showGrids = true,
    this.gridsColor = const Color(0xff4b4b4b),
    this.gridsMaxTile = 10,
    this.gridsTileSize = 1.0,
  });

  @override
  _Fbx3DViewerState createState() => fbx3DViewerController.state;
}

class Fbx3DViewerController extends StatefulWidget {
  final _Fbx3DViewerState state = _Fbx3DViewerState();

  reload() async => await state.reload();

  rotateX(v) => state.rotateX(v);

  rotateY(v) => state.rotateY(v);

  rotateZ(v) => state.rotateZ(v);

  reset() => state.reset();

  refresh() {
    if (state.fbx3DRenderer != null) state.fbx3DRenderer.refresh();
  }

  @override
  State<StatefulWidget> createState() => state;

  setLightPosition(Math.Vector3 lightPosition) => state.setLightPosition(lightPosition);

  showWireframe(bool showWireframe) => state.showWireframe(showWireframe);

  getWidget() => state.widget;

  setRandomColors(Color color, Color lightColor) => state.setRandomColors(color, lightColor);

  setColor(Color color) => state.setColor(color);

  setLightColor(Color color) => state.setLightColor(color);
}

class _Fbx3DViewerState extends State<Fbx3DViewer> {
  double angleX = 0.0;
  double angleY = 0.0;
  double angleZ = 0.0;
  double previousZoom;
  Offset startingFocalPoint;
  Offset previousOffset;
  Offset offset = Offset.zero;
  Fbx3DModel model;
  bool isLoading = false;
  TextureData textureData;
  var rotation = Math.Vector3(0, 0, 0);
  double zoom;
  Fbx3DRenderer fbx3DRenderer;

  initState() {
    super.initState();
    _init();
  }

  reload() async => await _parse();

  reset() async => fbx3DRenderer = null;

  _init() async => _parse();

  _parse() async {
    logger("___PARSE ${widget.fbxPath}");

    setState(() => isLoading = true);

    fbx3DRenderer = null;
    zoom = widget.initialZoom;

    if (!widget.fbxPath.startsWith("assets/")) {
      var pathFbx = widget.fbxPath;
      var fileFbx = File(pathFbx);

      if (await fileFbx.exists()) {
        var contFbx = await fileFbx.readAsString();
        _newModel(contFbx);
      }
    } else {
      final cont = await rootBundle.loadString(widget.fbxPath);
      _newModel(cont);
    }

    if (widget.texturePath != null) {
      textureData = TextureData();
      await textureData.load(context, widget.texturePath, resizeWidth: 200);
    }
    logger("load ${widget.texturePath}");

    paintRasterizer.shader = null;

    setState(() => isLoading = false);
  }

  _newModel(String contFbx) {
    model = Fbx3DModel();
    model.parseFrom(context, contFbx);

    if (widget.initialAngles != null) {
      setRotation(widget.initialAngles);
    }
  }

  setRotation(Math.Vector3 r) {
    angleX = r.x;
    angleY = r.y;
    angleZ = r.z;
    _rotationChanged();
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  rotateX(double v) {
    angleX += v;
    if (angleX > 360)
      angleX = angleX - 360;
    else if (angleX < 0) angleX = 360 - angleX;
    _rotationChanged();
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  rotateY(double v) {
    angleY += v;
    if (angleY > 360)
      angleY = angleY - 360;
    else if (angleY < 0) angleY = 360 - angleY;
    _rotationChanged();
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  rotateZ(double v) {
    angleZ += v;
    if (angleZ > 360)
      angleZ = angleZ - 360;
    else if (angleZ < 0) angleZ = 360 - angleZ;
    _rotationChanged();
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  _rotationChanged() {
    rotation.setValues(angleX, angleY, angleZ);
    if (widget.onRotationChangeListener != null) widget.onRotationChangeListener(rotation);
  }

  _handleScaleStart(initialFocusPoint) {
    startingFocalPoint = initialFocusPoint;
    previousOffset = offset;
    previousZoom = zoom;
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  _handleScaleUpdate(changedFocusPoint, scale) {
    zoom = previousZoom * scale;
    final Offset normalizedOffset = (startingFocalPoint - previousOffset) / previousZoom;
    offset = changedFocusPoint - normalizedOffset * zoom;
    if (widget.onZoomChangeListener != null) widget.onZoomChangeListener(zoom);
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.black));
    } else {
      if (fbx3DRenderer == null) {
        fbx3DRenderer = Fbx3DRenderer(widget);
        fbx3DRenderer.refresh();
      }

      return ZoomGestureDetector(
        child: CustomPaint(
          painter: fbx3DRenderer,
          size: widget.size,
        ),
        onScaleStart: (initialFocusPoint) => _handleScaleStart(initialFocusPoint),
        onScaleUpdate: (changedFocusPoint, scale) => _handleScaleUpdate(changedFocusPoint, scale),
        onHorizontalDragUpdate: (double dx) => widget.onHorizontalDragUpdate(dx),
        onVerticalDragUpdate: (double dy) => widget.onVerticalDragUpdate(dy),
        panDistanceToActivate: widget.panDistanceToActivate,
      );
    }
  }

  setLightPosition(Math.Vector3 lightPosition) {
    widget.lightPosition = lightPosition;
    if (fbx3DRenderer != null) fbx3DRenderer.refresh();
  }

  showWireframe(bool showWireframe) {
    widget.showWireframe = showWireframe;

    if (fbx3DRenderer != null) {
      fbx3DRenderer.reset();
      Future.delayed(Duration(milliseconds: 100), () {
        fbx3DRenderer.refresh();
      });
    }
  }

  setRandomColors(Color color, Color lightColor) {
    widget.color = color;
    widget.lightColor = lightColor;

    if (fbx3DRenderer != null) {
      fbx3DRenderer.reset();
      Future.delayed(Duration(milliseconds: 100), () => fbx3DRenderer.refresh());
    }
  }

  setColor(Color color) {
    widget.color = color;

    if (fbx3DRenderer != null) {
      fbx3DRenderer.reset();
      Future.delayed(Duration(milliseconds: 100), () => fbx3DRenderer.refresh());
    }
  }

  setLightColor(Color color) {
    widget.lightColor = color;

    if (fbx3DRenderer != null) {
      fbx3DRenderer.reset();
      Future.delayed(Duration(milliseconds: 100), () => fbx3DRenderer.refresh());
    }
  }
}

class Fbx3DRenderer extends ChangeNotifier implements CustomPainter {
  Paint paintFill = Paint();
  Paint paintWireframe = Paint();
  Paint paintGrids = Paint();
  Paint paintGridsMain = Paint();
  Paint paintBackground = Paint();
  Fbx3DViewer widget;

  Fbx3DRenderer(this.widget) {
    paintFill.style = PaintingStyle.fill;
    paintWireframe.style = PaintingStyle.stroke;
    paintWireframe.color = widget.wireframeColor;
    paintGrids.style = PaintingStyle.stroke;
    paintGrids.color = widget.gridsColor;
    paintGridsMain.style = PaintingStyle.stroke;
    paintGridsMain.color = Colors.black;
    paintGridsMain.strokeWidth = 1;
    paintBackground.color = widget.backgroundColor;
  }

  _transformVertex(Math.Vector3 vertex) {
    final _viewPortX = (widget.size.width / 2).toDouble();
    final _viewPortY = (widget.size.height / 2).toDouble();

    final trans = Math.Matrix4.translationValues(_viewPortX, _viewPortY, 1);
    trans.scale(widget.currentState().zoom, -widget.currentState().zoom);
    trans.rotateX(MathUtils.degreeToRadian(widget.currentState().angleX));
    trans.rotateY(MathUtils.degreeToRadian(widget.currentState().angleY));
    trans.rotateZ(MathUtils.degreeToRadian(widget.currentState().angleZ));
    return trans.transform3(vertex);
  }

  _drawTriangle(
      Canvas canvas, Math.Vector3 v1, Math.Vector3 v2, Math.Vector3 v3, Math.Vector2 uv1, Math.Vector2 uv2, Math.Vector2 uv3, Math.Vector3 n1, Math.Vector3 n2, Math.Vector3 n3) {
    final path = Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v1.x, v1.y);
    path.close();

    final color = widget.color;
    final lightPosition = widget.lightPosition;
    final lightColor = widget.lightColor;

    /*
    final normalVector = MathUtils.normalVector3(v1, v2, v3);
    Math.Vector3 normalizedLight = Math.Vector3.copy(lightPosition).normalized();
    final jnv = Math.Vector3.copy(normalVector).normalized();
    final normal = MathUtils.scalarMultiplication(jnv, normalizedLight);
    final brightness = normal.clamp(0.1, 1.0);

    if (widget.drawMode == DrawMode.WIREFRAME) {
      canvas.drawPath(path, paintWireframeBlue);
    } else if (widget.drawMode == DrawMode.SHADED) {
      final shade = Color.lerp(color, lightColor, brightness);
      paintFill.color = shade;
      canvas.drawPath(path, paintFill);
    } else if (widget.drawMode == DrawMode.TEXTURED) {
      if (widget.rasterizerMethod == RasterizerMethod.OldMethod)
        drawTexturedTrianglePoints(canvas, depthBuffer, v1, v2, v3, uv1, uv2, uv3, n1, n2, n3, color, brightness,
            widget.currentState().textureData, lightPosition);
      else if (widget.rasterizerMethod == RasterizerMethod.NewMethod)*/
    drawTexturedTriangleVertices(canvas, v1, v2, v3, uv1, uv2, uv3, n1, n2, n3, color, widget.currentState().textureData, lightPosition, lightColor);
    //}

    if (widget.showWireframe ?? false == true) {
      canvas.drawPath(path, paintWireframe);
    }
  }

  _drawGrids(Canvas canvas) {
    final steps = widget.gridsTileSize;
    final distance = (widget.gridsMaxTile * steps).toInt();

    for (int i = -distance ~/ steps; i <= distance ~/ steps; i++) {
      final p1 = gen2DPointFrom3D(_transformVertex(Math.Vector3(-distance.toDouble(), 0, -i * steps.toDouble())));
      final p2 = gen2DPointFrom3D(_transformVertex(Math.Vector3(distance.toDouble(), 0, -i * steps.toDouble())));
      canvas.drawLine(p1, p2, paintGrids);

      final p3 = gen2DPointFrom3D(_transformVertex(Math.Vector3(-distance.toDouble(), 0, i * steps.toDouble())));
      final p4 = gen2DPointFrom3D(_transformVertex(Math.Vector3(distance.toDouble(), 0, i * steps.toDouble())));
      canvas.drawLine(p3, p4, paintGrids);

      if (i == 0) {
        canvas.drawLine(p1, p2, paintGridsMain);
      }
    }

    for (int i = -distance ~/ steps; i <= distance ~/ steps; i++) {
      final p1 = gen2DPointFrom3D(_transformVertex(Math.Vector3(-i * steps.toDouble(), 0, -distance.toDouble())));
      final p2 = gen2DPointFrom3D(_transformVertex(Math.Vector3(-i * steps.toDouble(), 0, distance.toDouble())));
      canvas.drawLine(p1, p2, paintGrids);

      final p3 = gen2DPointFrom3D(_transformVertex(Math.Vector3(i * steps.toDouble(), 0, -distance.toDouble())));
      final p4 = gen2DPointFrom3D(_transformVertex(Math.Vector3(i * steps.toDouble(), 0, distance.toDouble())));
      canvas.drawLine(p3, p4, paintGrids);

      if (i == 0) {
        canvas.drawLine(p1, p2, paintGridsMain);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(paintBackground);

    if (widget.showGrids) {
      _drawGrids(canvas);
    }

    final model = widget.currentState().model;

    if (model == null) return;

    if (model.scene != null) {
      model.scene.currentFrame += widget.animationSpeed;
      if (model.scene.currentFrame >= widget.endFrame) {
        model.scene.currentFrame = model.scene.startFrame;
      }
    }

    if (model.objects.length == 0) {
      final sHead = "${widget.fbxPath}";
      final sDesc = "Null objects found!";
      drawErrorText(canvas, sHead, sDesc);
      return;
    }

    int vCount = 0;
    int verticesCount = 0;
    int triangleCount = 0;

    for (int i = 0; i < model.objects.length; i++) {
      Fbx3DObject obj = model.objects[i];
      obj.update();
      vCount += obj.points.length ~/ 3;
    }
    if (vCount > MAX_SUPPORTED_VERTICES) {
      final sHead = "${widget.fbxPath}";
      final sDesc = "Too much points: $vCount! Max supported points: $MAX_SUPPORTED_VERTICES!";
      drawErrorText(canvas, sHead, sDesc);
      return;
    }

    for (int i = 0; i < model.objects.length; i++) {
      final obj = model.objects[i];

      if (obj.skinIndices == null) {
        final sHead = "${widget.fbxPath}";
        final sDesc = "SkinIndices not set!";
        drawErrorText(canvas, sHead, sDesc);
        return;
      }
      if (obj.skinWeights == null) {
        final sHead = "${widget.fbxPath}";
        final sDesc = "SkinWeights not set!";
        drawErrorText(canvas, sHead, sDesc);
        return;
      }

      final oPoints = obj.points;
      final oIndices = obj.indices;
      final oNormals = obj.normals;
      final oUVs = obj.uvs;
      final sortedItems = List<Map<String, dynamic>>();

      final oJointMatrix = listMatrixFromFloat32List(obj.skinPalette);
      final oSkinIndices = listVector4FromFloat32List(obj.skinIndices);
      final oSkinWeights = listVector4FromFloat32List(obj.skinWeights);

      //1 a pontokbol keszitek egy Vec3 listet
      final List<Math.Vector3> tempVertices = List();
      final List<Math.Vector3> tempNormals = List();
      final List<Math.Vector3> tempUVs = List();

      for (int index = 0; index < oPoints.length; index += 3) {
        final p1 = oPoints[index];
        final p2 = oPoints[index + 1];
        final p3 = oPoints[index + 2];
        final v = Math.Vector3(p1, p2, p3);
        tempVertices.add(v);

        final n1 = oNormals[index];
        final n2 = oNormals[index + 1];
        final n3 = oNormals[index + 2];
        final n = Math.Vector3(n1, n2, n3);
        tempNormals.add(n);

        final uv1 = oUVs[index];
        final uv2 = oUVs[index + 1];
        final uv3 = oUVs[index + 2];
        final uv = Math.Vector3(uv1, uv2, uv3);
        tempUVs.add(uv);
      }

      //get the _getMaxWeightsPerVertex()
      _getMaxWeightsPerVertex(tempVertices, oSkinWeights);

      final List<Math.Vector3> bonedVertices = List();
      final List<Math.Vector3> tempNormals2 = List();

      for (int index = 0; index < tempVertices.length; index++) {
        final skinIndexX = oSkinIndices[index].x;
        final skinIndexY = oSkinIndices[index].y;
        final skinIndexZ = oSkinIndices[index].z;
        final skinIndexW = oSkinIndices[index].w;
        final skinWeightX = oSkinWeights[index].x;
        final skinWeightY = oSkinWeights[index].y;
        final skinWeightZ = oSkinWeights[index].z;
        final skinWeightW = oSkinWeights[index].w;

        final bv =
            _Fbx3DBones.calculateBoneVertex(tempVertices[index], skinIndexX, skinIndexY, skinIndexZ, skinIndexW, skinWeightX, skinWeightY, skinWeightZ, skinWeightW, oJointMatrix);
        bonedVertices.add(bv);

        final bn =
            _Fbx3DBones.calculateBoneNormal(tempNormals[index], skinIndexX, skinIndexY, skinIndexZ, skinIndexW, skinWeightX, skinWeightY, skinWeightZ, skinWeightW, oJointMatrix);
        tempNormals2.add(bn);
      }

      verticesCount += bonedVertices.length;

      final List<double> newPoints = List();
      final List<double> newNormals = List();
      final List<double> newUVs = List();

      for (int index = 0; index < bonedVertices.length; index++) {
        newPoints.add(bonedVertices[index].x);
        newPoints.add(bonedVertices[index].y);
        newPoints.add(bonedVertices[index].z);

        newNormals.add(tempNormals2[index].x);
        newNormals.add(tempNormals2[index].y);
        newNormals.add(tempNormals2[index].z);

        newUVs.add(tempUVs[index].x);
        newUVs.add(tempUVs[index].y);
        newUVs.add(tempUVs[index].z);
      }

      final Float32List nPoints = Float32List.fromList(newPoints);
      final Float32List nNormals = Float32List.fromList(newNormals);
      final Float32List nUVs = Float32List.fromList(newUVs);

      final List<Math.Vector3> vertices = List();
      final List<Math.Vector3> normals = List();
      final List<Math.Vector2> uvs = List();

      for (int index = 0; index < oIndices.length; index += 3) {
        Math.Vector3 v1 = _transformVertex(Math.Vector3(nPoints[oIndices[index] * 3], nPoints[oIndices[index] * 3 + 1], nPoints[oIndices[index] * 3 + 2]));
        Math.Vector3 v2 = _transformVertex(Math.Vector3(nPoints[oIndices[index + 1] * 3], nPoints[oIndices[index + 1] * 3 + 1], nPoints[oIndices[index + 1] * 3 + 2]));
        Math.Vector3 v3 = _transformVertex(Math.Vector3(nPoints[oIndices[index + 2] * 3], nPoints[oIndices[index + 2] * 3 + 1], nPoints[oIndices[index + 2] * 3 + 2]));
        vertices.add(v1);
        vertices.add(v2);
        vertices.add(v3);

        Math.Vector3 n1 = Math.Vector3(nNormals[oIndices[index] * 3], nNormals[oIndices[index] * 3 + 1], nNormals[oIndices[index] * 3 + 2]);
        Math.Vector3 n2 = Math.Vector3(nNormals[oIndices[index + 1] * 3], nNormals[oIndices[index + 1] * 3 + 1], nNormals[oIndices[index + 1] * 3 + 2]);
        Math.Vector3 n3 = Math.Vector3(nNormals[oIndices[index + 2] * 3], nNormals[oIndices[index + 2] * 3 + 1], nNormals[oIndices[index + 2] * 3 + 2]);
        normals.add(n1);
        normals.add(n2);
        normals.add(n3);

        Math.Vector2 uv1 = Math.Vector2(nUVs[oIndices[index] * 2], nUVs[oIndices[index] * 2 + 1]);
        Math.Vector2 uv2 = Math.Vector2(nUVs[oIndices[index + 1] * 2], nUVs[oIndices[index + 1] * 2 + 1]);
        Math.Vector2 uv3 = Math.Vector2(nUVs[oIndices[index + 2] * 2], nUVs[oIndices[index + 2] * 2 + 1]);
        uvs.add(uv1);
        uvs.add(uv2);
        uvs.add(uv3);
      }

      // painter's algorithm
      for (int index = 0; index < vertices.length; index += 3) {
        final Math.Vector3 v1 = vertices[index];
        final Math.Vector3 v2 = vertices[index + 1];
        final Math.Vector3 v3 = vertices[index + 2];

        final Math.Vector3 n1 = normals[index];
        final Math.Vector3 n2 = normals[index + 1];
        final Math.Vector3 n3 = normals[index + 2];

        final Math.Vector2 uv1 = uvs[index];
        final Math.Vector2 uv2 = uvs[index + 1];
        final Math.Vector2 uv3 = uvs[index + 2];

        sortedItems.add({
          "order": MathUtils.zIndex(v1, v2, v3),
          "v1": v1,
          "v2": v2,
          "v3": v3,
          "uv1": uv1,
          "uv2": uv2,
          "uv3": uv3,
          "n1": n1,
          "n2": n2,
          "n3": n3,
        });
      }
      sortedItems.sort((Map a, Map b) => a["order"].compareTo(b["order"]));

      //logger("????  " + sorted.length.toString() + " " + vertices.length.toString());

      //7 vegul a rendezett vertexeket kirajzolom 3-asaval, triangle-nkent
      for (int index = 0; index < sortedItems.length; index++) {
        final sorted = sortedItems[index];
        final v1 = Math.Vector3.copy(sorted['v1']);
        final v2 = Math.Vector3.copy(sorted['v2']);
        final v3 = Math.Vector3.copy(sorted['v3']);
        final uv1 = sorted['uv1'];
        final uv2 = sorted['uv2'];
        final uv3 = sorted['uv3'];
        final n1 = sorted['n1'];
        final n2 = sorted['n2'];
        final n3 = sorted['n3'];

        _drawTriangle(canvas, v1, v2, v3, uv1, uv2, uv3, n1, n2, n3);

        triangleCount++;
      }
    }

    _drawInfo(canvas, verticesCount, triangleCount);
  }

  _drawInfo(Canvas canvas, int verticesCount, int triangleCount) {
    if (widget.showInfo) {
      final rot = widget.currentState().rotation;
      final zoom = widget.currentState().zoom.toStringAsFixed(1);

      drawText(canvas, "vertices: " + verticesCount.toString(), Offset(20, ScreenUtils.height - 80));
      drawText(canvas, "triangles: " + triangleCount.toString(), Offset(20, ScreenUtils.height - 100));
      drawText(canvas, "endFrame: " + widget.endFrame.toString() + "  speed: " + widget.animationSpeed.toString(), Offset(20, ScreenUtils.height - 120));

      drawText(canvas, "zoom: " + zoom + " rot: (" + rot.x.toStringAsFixed(0) + ", " + rot.y.toStringAsFixed(0) + ", " + rot.z.toStringAsFixed(0) + ")",
          Offset(20, ScreenUtils.height - 150),
          fontSize: 14);

      drawText(canvas, "path: " + widget.fbxPath, Offset(20, ScreenUtils.height - 185), fontSize: 12);
    }
  }

  @override
  bool shouldRepaint(Fbx3DRenderer old) => true;

  refresh() => notifyListeners();

  reset() {
    if (widget.fbx3DViewerController != null) widget.fbx3DViewerController.reset();
  }

  @override
  bool hitTest(Offset position) => true;

  @override
  bool shouldRebuildSemantics(CustomPainter previous) => false;

  @override
  get semanticsBuilder => null;
}

//from jMonkeyEngine, normalize the weights
_getMaxWeightsPerVertex(List<Math.Vector3> tempVertices, List<Math.Vector4> oSkinWeights) {
  int maxWeightsPerVertex = 0;

  for (int index = 0; index < tempVertices.length; index++) {
    final w0 = oSkinWeights[index].x;
    final w1 = oSkinWeights[index].y;
    final w2 = oSkinWeights[index].z;
    final w3 = oSkinWeights[index].w;

    if (w3 != 0) {
      maxWeightsPerVertex = max(maxWeightsPerVertex, 4);
    } else if (w2 != 0) {
      maxWeightsPerVertex = max(maxWeightsPerVertex, 3);
    } else if (w1 != 0) {
      maxWeightsPerVertex = max(maxWeightsPerVertex, 2);
    } else if (w0 != 0) {
      maxWeightsPerVertex = max(maxWeightsPerVertex, 1);
    }

    double sum = w0 + w1 + w2 + w3;
    if (sum != 1.0) {
      double normalized = (sum != 0) ? (1.0 / sum) : 0.0;
      oSkinWeights[index].x = (w0 * normalized);
      oSkinWeights[index].y = (w1 * normalized);
      oSkinWeights[index].z = (w2 * normalized);
      oSkinWeights[index].w = (w3 * normalized);
    }
  }
  return maxWeightsPerVertex;
}

class _Fbx3DBones {
  _Fbx3DBones._();

  static Math.Vector3 calculateBoneVertex(vertexPosition, skinIndexX, skinIndexY, skinIndexZ, skinIndexW, skinWeightX, skinWeightY, skinWeightZ, skinWeightW, joints) {
    Math.Vector4 p = Math.Vector4(vertexPosition.x, vertexPosition.y, vertexPosition.z, 1.0);

    Math.Vector4 sp = Math.Vector4(0.0, 0.0, 0.0, 0.0);
    int index = 0;

    index = skinIndexX.toInt();
    sp = (joints[index] * p) * skinWeightX;

    index = skinIndexY.toInt();
    sp += (joints[index] * p) * skinWeightY;

    index = skinIndexZ.toInt();
    sp += (joints[index] * p) * skinWeightZ;

    index = skinIndexW.toInt();
    sp += (joints[index] * p) * skinWeightW;

    return sp.xyz;
  }

  static Math.Vector3 calculateBoneNormal(vertexNormal, skinIndexX, skinIndexY, skinIndexZ, skinIndexW, skinWeightX, skinWeightY, skinWeightZ, skinWeightW, joints) {
    Math.Vector3 n = Math.Vector3(vertexNormal.x, vertexNormal.y, vertexNormal.z);

    Math.Vector3 sn = Math.Vector3(0.0, 0.0, 0.0);
    int index = 0;

    index = skinIndexX.toInt();
    sn = (joints[index] * n) * skinWeightX;

    index = skinIndexY.toInt();
    sn += (joints[index] * n) * skinWeightY;

    index = skinIndexZ.toInt();
    sn += (joints[index] * n) * skinWeightZ;

    index = skinIndexW.toInt();
    sn += (joints[index] * n) * skinWeightW;

    return sn.xyz;
  }
}
