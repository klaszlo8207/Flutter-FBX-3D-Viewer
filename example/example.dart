import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/flutter_fbx3d_viewer.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/screen_utils.dart';
import 'package:flutter_fbx3d_viewer/fbx_viewer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as Math;

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class Object3DDetails {
  String animationPath;
  String animationTexturePath;
  Math.Vector3 rotation;
  double zoom;
  Color color, lightColor;
  double gridTileSize;
  int animationLength;
  double animationSpeed;

  Object3DDetails(this.animationPath, this.animationTexturePath, this.rotation, this.zoom, this.animationLength, this.animationSpeed,
      {this.color = Colors.black, this.lightColor = Colors.white, this.gridTileSize = 0.5});
}

List<Object3DDetails> _objects = [
  Object3DDetails(
    "assets/turtle.fbx",
    "assets/turtle.png",
    Math.Vector3(216, 10, 230),
    3,
    25,
    0.4,
    color: Colors.black.withOpacity(0.2),
    lightColor: Colors.white.withOpacity(0.7),
    gridTileSize: 15.0,
  ),
  Object3DDetails(
    "assets/teddy_walk.fbx",
    "assets/teddy.png",
    Math.Vector3(86, 10, 40),
    140,
    32,
    1.0,
    color: Colors.black.withOpacity(0.7),
    lightColor: Colors.white.withOpacity(0.3),
  ),
  Object3DDetails(
    "assets/teddy_idle.fbx",
    "assets/teddy.png",
    Math.Vector3(86, 10, 40),
    140,
    110,
    1.5,
    color: Colors.black.withOpacity(0.7),
    lightColor: Colors.white.withOpacity(0.3),
  ),
  Object3DDetails(
    "assets/knight.fbx",
    "assets/knight.png",
    Math.Vector3(260, 10, 0),
    30,
    16,
    0.7,
    color: Colors.black.withOpacity(0.8),
    lightColor: Colors.white.withOpacity(0.2),
    gridTileSize: 2,
  ),
  Object3DDetails(
    "assets/chipmunk.fbx",
    "assets/chipmunk.png",
    Math.Vector3(86, 10, 40),
    140,
    32,
    1.0,
    color: Colors.black.withOpacity(0.7),
    lightColor: Colors.white.withOpacity(0.3),
  ),
  Object3DDetails(
    "assets/shark.fbx",
    "assets/shark.png",
    Math.Vector3(86, 10, 40),
    140,
    32,
    1.0,
    color: Colors.black.withOpacity(0.7),
    lightColor: Colors.white.withOpacity(0.3),
  ),
];

class ChangeVariants with ChangeNotifier {
  bool _showWireframe = false;
  int _objIndex = 0;
  double _lightAngle = 0.0;
  Math.Vector3 _lightPosition = Math.Vector3(20.0, 20.0, 10.0);
  bool _rndColor = false;

  bool get rndColor => _rndColor;

  int get objIndex => _objIndex;

  double get lightAngle => _lightAngle;

  Math.Vector3 get lightPosition => _lightPosition;

  bool get showWireframe => _showWireframe;

  set rndColor(bool value) {
    _rndColor = value;
  }

  set objIndex(int value) {
    _objIndex = value;
    notifyListeners();
  }

  set showWireframe(bool value) {
    _showWireframe = value;
    notifyListeners();
  }

  set lightAngle(double value) {
    _lightAngle = value;
    notifyListeners();
  }

  set lightPosition(Math.Vector3 value) {
    _lightPosition = value;
    notifyListeners();
  }
}

class _ExampleState extends State<Example> {
  Fbx3DViewerController _fbx3DAnimationController;
  Timer _renderTimer;
  ChangeVariants _changeVariantsSet;

  _ExampleState() {
    _fbx3DAnimationController = Fbx3DViewerController();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _changeVariantsSet = Provider.of<ChangeVariants>(context, listen: false);
    _fbx3DAnimationController = Fbx3DViewerController();
    _startTimer();
  }

  _startTimer() {
    _renderTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      final d = 10.0;
      _changeVariantsSet.lightAngle += 0.8;
      if (_changeVariantsSet.lightAngle > 360) _changeVariantsSet.lightAngle = 0;
      double fx = sin(Math.radians(_changeVariantsSet.lightAngle)) * d;
      double fz = cos(Math.radians(_changeVariantsSet.lightAngle)) * d;
      _changeVariantsSet.lightPosition.setValues(-fx, -fz, 0);
      _fbx3DAnimationController.setLightPosition(_changeVariantsSet.lightPosition);
    });
  }

  _endTimer() => _renderTimer.cancel();

  @override
  void dispose() {
    super.dispose();
    _endTimer();
  }

  _nextObj() async {
    _changeVariantsSet.objIndex++;
    if (_changeVariantsSet.objIndex >= _objects.length) _changeVariantsSet.objIndex = 0;
    _fbx3DAnimationController.refresh();

    Future.delayed(Duration(milliseconds: 50), () {
      _fbx3DAnimationController.reload().then((_) {
        Future.delayed(Duration(milliseconds: 100), () {
          _fbx3DAnimationController.refresh();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);

    final changeVariantsGet = Provider.of<ChangeVariants>(context);
    final object = _objects[changeVariantsGet.objIndex];

    return Scaffold(
        backgroundColor: const Color(0xff353535),
        body: SafeArea(
            child: Stack(
              children: <Widget>[
                Fbx3DViewer(
                  lightPosition: Math.Vector3(20, 10, 10),
                  lightColor: Colors.black.withOpacity(0.2),
                  color: changeVariantsGet._rndColor ? randomColor(opacity: 0.8) : Colors.black.withOpacity(0.8),
                  refreshMilliseconds: 1,
                  size: Size(ScreenUtils.width, ScreenUtils.height),
                  initialZoom: object.zoom,
                  endFrame: object.animationLength,
                  initialAngles: object.rotation,
                  fbxPath: object.animationPath,
                  texturePath: object.animationTexturePath,
                  animationSpeed: object.animationSpeed,
                  fbx3DViewerController: _fbx3DAnimationController,
                  showInfo: true,
                  showWireframe: changeVariantsGet._showWireframe,
                  wireframeColor: changeVariantsGet._rndColor ? randomColor(opacity: 0.5) : Colors.blue.withOpacity(0.5),
                  onHorizontalDragUpdate: (d) {
                    if (object.animationPath.contains("turtle") || object.animationPath.contains("knight"))
                      _fbx3DAnimationController.rotateZ(d);
                    else
                      _fbx3DAnimationController.rotateZ(-d);
                  },
                  onVerticalDragUpdate: (d) => _fbx3DAnimationController.rotateX(d),
                  onZoomChangeListener: (zoom) => object.zoom = zoom,
                  onRotationChangeListener: (Math.Vector3 rotation) => object.rotation.setFrom(rotation),
                  panDistanceToActivate: 50,
                  gridsTileSize: object.gridTileSize,
                ),
                FlatButton(
                  color: Colors.white,
                  child: Text("Change model"),
                  onPressed: () => _nextObj(),
                ),
                Align(
                  child: SizedBox(
                      height: 120,
                      width: ScreenUtils.width / 2,
                      child: Column(
                        children: <Widget>[
                          CheckboxListTile(
                            title: Text("Wireframe"),
                            value: changeVariantsGet._showWireframe,
                            onChanged: (v) {
                              _changeVariantsSet.showWireframe = v;
                              _fbx3DAnimationController.showWireframe(_changeVariantsSet.showWireframe);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            title: Text("Rnd colors"),
                            value: changeVariantsGet._rndColor,
                            onChanged: (v) {
                              _changeVariantsSet.rndColor = v;
                              _fbx3DAnimationController.setRandomColors(randomColor(opacity: 0.7), randomColor(opacity: 0.3));
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          )
                        ],
                      )),
                  alignment: Alignment.topRight,
                )
              ],
            )));
  }
}
