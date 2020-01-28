library flutter_fbx3d_viewer;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fbx3d_viewer/widgets/zoom_gesture_detector.dart';
import 'package:flutter_fbx3d_viewer/fbx3d_model.dart';
import 'package:flutter_fbx3d_viewer/fbx3d_object.dart';
import 'package:flutter_fbx3d_viewer/utils/math_utils.dart';
import 'package:flutter_fbx3d_viewer/utils/screen_utils.dart';
import 'package:vector_math/vector_math.dart' as Math;

/// Created by Kozári László 2020.01.16
/// This is a simple non textured Fbx animated 3d file viewer.
///
class Fbx3DViewer extends StatefulWidget {
  final Size size;
  final String path;
  final bool fromAsset;
  final bool showInfo;
  final bool rotateX;
  final bool rotateY;
  final bool rotateZ;
  final bool showWireframe;
  final Color wireframeColor;
  final Math.Vector3 initialAngles;
  double zoom;

  Fbx3DViewer({
    @required this.size,
    @required this.path,
    @required this.fromAsset,
    @required this.zoom,
    this.showInfo = false,
    this.showWireframe = false,
    this.wireframeColor = Colors.black,
    this.rotateX = false,
    this.rotateY = false,
    this.rotateZ = false,
    this.initialAngles,
  });

  @override
  _Fbx3DViewerState createState() => _Fbx3DViewerState();
}

class _Fbx3DViewerState extends State<Fbx3DViewer> {
  double _angleX = 0.0;
  double _angleY = 0.0;
  double _angleZ = 0.0;
  double _previousZoom;
  Offset _startingFocalPoint;
  Offset _previousOffset;
  Offset _offset = Offset.zero;
  Fbx3DModel _fbxModel;
  Timer _renderTimer;

  initState() {
    super.initState();
    _init();
  }

  _init() async {
    if (!widget.fromAsset) {
      //mi csak ezt hasznaljuk egyelore
      var pathFbx = widget.path;
      var fileFbx = File(pathFbx);

      if (await fileFbx.exists()) {
        var contFbx = await fileFbx.readAsString();
        _newModel(contFbx);
      }
    } else {
      rootBundle.loadString(widget.path).then((cont) {
        _newModel(cont);
      });
    }

    if (widget.rotateX || widget.rotateY || widget.rotateZ) _startRefresh();
  }

  _newModel(String contFbx) {
    setState(() {
      _fbxModel = Fbx3DModel();
      _fbxModel.parseFrom(context, contFbx);
    });

    if (widget.initialAngles != null) {
      _rotateX(widget.initialAngles.x);
      _rotateY(widget.initialAngles.y);
      //_rotateZ(widget.initialAngles.z);
    }
  }

  @override
  void dispose() {
    if (widget.rotateX || widget.rotateY || widget.rotateZ) _endRefresh();
    super.dispose();
  }

  _rotateX(double v) {
    _angleX += v;
    if (_angleX > 360)
      _angleX = _angleX - 360;
    else if (_angleX < 0) _angleX = 360 - _angleX;
  }

  _rotateY(double v) {
    _angleY += v;
    if (_angleY > 360)
      _angleY = _angleY - 360;
    else if (_angleY < 0) _angleY = 360 - _angleY;
  }

  _rotateZ(double v) {
    _angleZ += v;
    if (_angleZ > 360)
      _angleZ = _angleZ - 360;
    else if (_angleZ < 0) _angleZ = 360 - _angleZ;
  }

  _startRefresh() {
    _renderTimer = Timer.periodic(const Duration(milliseconds: 10), (t) {
      if (widget.rotateX) {
        _rotateY(1.2);
      }
      if (widget.rotateY) {
        _rotateX(1.2);
      }
      if (widget.rotateZ) {
        _rotateZ(1.2);
      }

      setState(() {});
    });
  }

  _endRefresh() => _renderTimer?.cancel();

  _handlePanX(double dx) {
    _rotateY(dx);
    setState(() {});
  }

  _handlePanY(double dy) {
    _rotateX(dy);
    setState(() {});
  }

  _handlePanZ(double dz) {
    _rotateZ(dz);
    setState(() {});
  }

  _handleScaleStart(initialFocusPoint) {
    setState(() {
      _startingFocalPoint = initialFocusPoint;
      _previousOffset = _offset;
      _previousZoom = widget.zoom;
    });
  }

  _handleScaleUpdate(changedFocusPoint, scale) {
    setState(() {
      widget.zoom = _previousZoom * scale;
      final Offset normalizedOffset = (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = changedFocusPoint - normalizedOffset * widget.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 10), () => setState(() {}));

    return ZoomGestureDetector(
      child: CustomPaint(
        painter: _Fbx3DRenderer(widget, _fbxModel, _angleX, _angleY, _angleZ),
        size: widget.size,
      ),
      onScaleStart: (initialFocusPoint) => _handleScaleStart(initialFocusPoint),
      onScaleUpdate: (changedFocusPoint, scale) => _handleScaleUpdate(changedFocusPoint, scale),
      onHorizontalDragUpdate: (double dx) => _handlePanZ(dx),
      onVerticalDragUpdate: (double dy) => _handlePanY(dy),
    );
  }
}

class _Fbx3DRenderer extends CustomPainter {
  double _viewPortX = 0.0;
  double _viewPortY = 0.0;
  Math.Vector3 _light;
  double _angleX;
  double _angleY;
  double _angleZ;
  final Fbx3DModel _model;
  final _watch = Stopwatch();
  Paint _paintFill = Paint();
  Paint _paintWireframe = Paint();
  Fbx3DViewer _widget;

  _Fbx3DRenderer(this._widget, this._model, this._angleX, this._angleY, this._angleZ) {
    _light = Math.Vector3(0.0, 0.0, 100.0);
    _viewPortX = (_widget.size.width / 2).toDouble();
    _viewPortY = (_widget.size.height / 2).toDouble();
    _paintFill.style = PaintingStyle.fill;
    _paintWireframe.style = PaintingStyle.stroke;
    _paintWireframe.color = _widget.wireframeColor;
  }

  Math.Vector3 _calcVertex(Math.Vector3 vertex) {
    var trans = Math.Matrix4.translationValues(_viewPortX, _viewPortY, 1);
    trans.scale(_widget.zoom, -_widget.zoom);
    trans.rotateX(MathUtils.degreeToRadian(_angleX));
    trans.rotateY(MathUtils.degreeToRadian(_angleY));
    trans.rotateZ(MathUtils.degreeToRadian(_angleZ));
    return trans.transform3(vertex);
  }

  _drawFace(Canvas canvas, Math.Vector3 v1, Math.Vector3 v2, Math.Vector3 v3, Math.Vector3 n1, Math.Vector3 n2, Math.Vector3 n3, Color color) {
    // Calculate the lighting
    var normalVector = MathUtils.normalVector3(v1, v2, v3);
    Math.Vector3 normalizedLight = Math.Vector3.copy(_light).normalized();
    var jnv = Math.Vector3.copy(normalVector).normalized();
    var normal = MathUtils.scalarMultiplication(jnv, normalizedLight);
    var brightness = normal.clamp(0.2, 1.0);

    // Assign a lighting color
    var r = (brightness * color.red).toInt();
    var g = (brightness * color.green).toInt();
    var b = (brightness * color.blue).toInt();

    _paintFill.color = Color.fromARGB(255, r, g, b);

    // Paint the face
    var path = Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v1.x, v1.y);
    path.close();

    if (_model.triangleShader == null) canvas.drawPath(path, _paintFill);
    else canvas.drawPath(path, _paintFill..shader = _model.triangleShader);

    //canvas.drawShadow(path, Colors.black45, 1.0, false);

    if (_widget.showWireframe) canvas.drawPath(path, _paintWireframe);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _watch.start();

    if (_model == null) return;

    if (_model.scene != null) {
      _model.scene.currentFrame += 0.4;
      if (_model.scene.currentFrame > _model.scene.endFrame) {
        _model.scene.currentFrame = _model.scene.startFrame;
      }
    }

    //for (int i = 0; i < _model.objects.length; i++) {
    Fbx3DObject obj = _model.objects[0]; //csak 0 elem //csak 1
    obj.update();

    var pPoints = obj.points;
    var oIndices = obj.indices;
    var oNormals = obj.normals;
    var sorted = List<Map<String, dynamic>>();

    var oJointMatrix = _listMatrixFromSkinPalette(obj.skinPalette);
    var oSkinIndices = _listVector4FromFloat32List(obj.skinIndices);
    var oSkinWeights = _listVector4FromFloat32List(obj.skinWeights);

    List<Math.Vector3> tempVertices = List();
    List<Math.Vector3> tempNormals = List();

    for (int index = 0; index < pPoints.length; index += 3) {
      final p1 = pPoints[index];
      final p2 = pPoints[index + 1];
      final p3 = pPoints[index + 2];

      final v = Math.Vector3(p1, p2, p3);
      tempVertices.add(v);

      final n1 = oNormals[index];
      final n2 = oNormals[index + 1];
      final n3 = oNormals[index + 2];

      final n = Math.Vector3(n1, n2, n3);
      tempNormals.add(n);
    }

    _getMaxWeightsPerVertex(tempVertices, oSkinWeights);

    List<Math.Vector3> tempVertices2 = List();
    List<Math.Vector3> tempNormals2 = List();

    for (int index = 0; index < tempVertices.length; index++) {
      final skinIndexX = oSkinIndices[index].x;
      final skinIndexY = oSkinIndices[index].y;
      final skinIndexZ = oSkinIndices[index].z;
      final skinIndexW = oSkinIndices[index].w;

      final skinWeightX = oSkinWeights[index].x;
      final skinWeightY = oSkinWeights[index].y;
      final skinWeightZ = oSkinWeights[index].z;
      final skinWeightW = oSkinWeights[index].w;

      final v = tempVertices[index];

      final bv = _Fbx3DBones.calculateBoneVertex(v, skinIndexX, skinIndexY, skinIndexZ, skinIndexW,
          skinWeightX, skinWeightY, skinWeightZ, skinWeightW, oJointMatrix);
      tempVertices2.add(bv);

      final n = tempNormals[index];

      final bn = _Fbx3DBones.calculateBoneNormal(n, skinIndexX, skinIndexY, skinIndexZ, skinIndexW,
          skinWeightX, skinWeightY, skinWeightZ, skinWeightW, oJointMatrix);
      tempNormals2.add(bn);
    }

    List<double> newPoints = List();
    List<double> newNormals = List();

    for (int index = 0; index < tempVertices2.length; index++) {
      newPoints.add(tempVertices2[index].x);
      newPoints.add(tempVertices2[index].y);
      newPoints.add(tempVertices2[index].z);

      newNormals.add(tempNormals2[index].x);
      newNormals.add(tempNormals2[index].y);
      newNormals.add(tempNormals2[index].z);
    }

    Float32List nPoints = Float32List.fromList(newPoints);
    Float32List nNormals = Float32List.fromList(newNormals);

    List<Math.Vector3> vertices = List();
    List<Math.Vector3> normals = List();

    for (int index = 0; index < oIndices.length; index += 3) {
      Math.Vector3 p1 = Math.Vector3(nPoints[oIndices[index] * 3], nPoints[oIndices[index] * 3 + 1], nPoints[oIndices[index] * 3 + 2]);
      Math.Vector3 p2 = Math.Vector3(nPoints[oIndices[index + 1] * 3], nPoints[oIndices[index + 1] * 3 + 1], nPoints[oIndices[index + 1] * 3 + 2]);
      Math.Vector3 p3 = Math.Vector3(nPoints[oIndices[index + 2] * 3], nPoints[oIndices[index + 2] * 3 + 1], nPoints[oIndices[index + 2] * 3 + 2]);

      Math.Vector3 v1 = _calcVertex(p1);
      Math.Vector3 v2 = _calcVertex(p2);
      Math.Vector3 v3 = _calcVertex(p3);

      vertices.add(v1);
      vertices.add(v2);
      vertices.add(v3);

      Math.Vector3 n1 = Math.Vector3(nNormals[oIndices[index] * 3], nNormals[oIndices[index] * 3 + 1], nNormals[oIndices[index] * 3 + 2]);
      Math.Vector3 n2 = Math.Vector3(nNormals[oIndices[index + 1] * 3], nNormals[oIndices[index + 1] * 3 + 1], nNormals[oIndices[index + 1] * 3 + 2]);
      Math.Vector3 n3 = Math.Vector3(nNormals[oIndices[index + 2] * 3], nNormals[oIndices[index + 2] * 3 + 1], nNormals[oIndices[index + 2] * 3 + 2]);

      normals.add(n1);
      normals.add(n2);
      normals.add(n3);
    }

    for (int index = 0; index < vertices.length; index += 3) {
      final Math.Vector3 v1 = vertices[index];
      final Math.Vector3 v2 = vertices[index + 1];
      final Math.Vector3 v3 = vertices[index + 2];

      final Math.Vector3 n1 = normals[index];
      final Math.Vector3 n2 = normals[index + 1];
      final Math.Vector3 n3 = normals[index + 2];

      sorted.add({
        "order": MathUtils.zIndex(v1, v2, v3),
        "v1": v1,
        "v2": v2,
        "v3": v3,
        "n1": n1,
        "n2": n2,
        "n3": n3,
      });
    }
    sorted.sort((Map a, Map b) => a["order"].compareTo(b["order"]));

    for (int index = 0; index < sorted.length; index++) {
      var v1 = sorted[index]["v1"];
      var v2 = sorted[index]["v2"];
      var v3 = sorted[index]["v3"];

      var n1 = sorted[index]["n1"];
      var n2 = sorted[index]["n2"];
      var n3 = sorted[index]["n3"];

      _drawFace(canvas, v1, v2, v3, n1, n2, n3, Colors.white);
    }

    if (_widget.showInfo) {
      String vertexCount = (obj.points.length / 3).toStringAsFixed(0);
      _drawText(canvas, "verts: " + vertexCount, Offset(20, ScreenUtils.height - 40));

      String fps = (1000 / _watch.elapsed.inMilliseconds).toStringAsFixed(0);
      _drawText(canvas, "fps: " + fps, Offset(20, ScreenUtils.height - 60));
    }

    _watch.stop();
  }

  List<Math.Vector4> _listVector4FromFloat32List(Float32List list) {
    List<Math.Vector4> vectors = List();
    for (int index = 0; index <= list.length - 4; index += 4) {
      var v = Math.Vector4(
        list[index],
        list[index + 1],
        list[index + 2],
        list[index + 3],
      );
      vectors.add(v);
    }
    return vectors;
  }

  List<Math.Matrix4> _listMatrixFromSkinPalette(Float32List skinPalette) {
    List<Math.Matrix4> matrices = List();
    for (int index = 0; index <= skinPalette.length - 16; index += 16) {
      var m = Math.Matrix4(
        skinPalette[index],
        skinPalette[index + 1],
        skinPalette[index + 2],
        skinPalette[index + 3],
        skinPalette[index + 4],
        skinPalette[index + 5],
        skinPalette[index + 6],
        skinPalette[index + 7],
        skinPalette[index + 8],
        skinPalette[index + 9],
        skinPalette[index + 10],
        skinPalette[index + 11],
        skinPalette[index + 12],
        skinPalette[index + 13],
        skinPalette[index + 14],
        skinPalette[index + 15],
      );
      matrices.add(m);
    }
    return matrices;
  }

  _drawText(Canvas canvas, String s, Offset offset) {
    final textStyle = TextStyle(color: Colors.white, fontSize: 20, shadows: [Shadow(blurRadius: 5, color: Colors.black, offset: const Offset(1, 1))]);
    final textSpan = TextSpan(text: s, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: _widget.size.width);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_Fbx3DRenderer old) => true;
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

  static Math.Vector3 calculateBoneVertex(vertexPosition, skinIndexX, skinIndexY, skinIndexZ, skinIndexW,
      skinWeightX, skinWeightY, skinWeightZ, skinWeightW, joints) {
    Math.Vector4 p = Math.Vector4(vertexPosition.x, vertexPosition.y, vertexPosition.z, 1.0);
    Math.Vector4 sp = Math.Vector4(0.0, 0.0, 0.0, 0.0);

    int index = skinIndexX.toInt();
    sp = (joints[index] * p) * skinWeightX;

    index = skinIndexY.toInt();
    sp += (joints[index] * p) * skinWeightY;

    index = skinIndexZ.toInt();
    sp += (joints[index] * p) * skinWeightZ;

    index = skinIndexW.toInt();
    sp += (joints[index] * p) * skinWeightW;

    return sp.xyz;
  }

  static Math.Vector3 calculateBoneNormal(vertexNormal, skinIndexX, skinIndexY, skinIndexZ, skinIndexW,
      skinWeightX, skinWeightY, skinWeightZ, skinWeightW, joints) {
    Math.Vector4 n = Math.Vector4(vertexNormal.x, vertexNormal.y, vertexNormal.z, 1.0);
    Math.Vector4 sn = Math.Vector4(0.0, 0.0, 0.0, 0.0);

    int index = skinIndexX.toInt();
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
