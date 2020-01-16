import 'package:flutter/material.dart';
import 'package:flutter_fbx3d_viewer/flutter_fbx3d_viewer.dart';
import 'package:flutter_fbx3d_viewer/utils/screen_utils.dart';
import 'package:vector_math/vector_math.dart' as Math;

class Example extends StatefulWidget {
  final String title;
  const Example({Key key, this.title}) : super(key: key);
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  Widget buildFbx3DView() {
    ScreenUtils.init(context);

    return Fbx3DViewer(
      size: Size(ScreenUtils.width, ScreenUtils.height),
      zoom: 30,
      path: "assets/knight_2014.fbx",
      fromAsset: true,
      showInfo: true,
      rotateX: false,
      rotateY: false,
      showWireframe: true,
      wireframeColor: Colors.blue,
      initialAngles: Math.Vector3(270, 10, 0),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildFbx3DView());
}
