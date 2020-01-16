# Flutter FBX 3D Viewer

Flutter package for viewing FBX 3D animated files

**This library is experimental. Some FBX files, particularly older fbx files, may not load correctly. No guarantee is provided as FBX is a closed proprietary format.**

This library is based on the [dart_fbx](https://github.com/brendan-duncan/dart_fbx) library


## Example

    Fbx3DViewer(
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
 
  
[FBX Viewer](https://github.com/klaszlo8207/Flutter-FBX-3D-Viewer/blob/master/example/example_app.dart)

**FBX is a closed format, so while this library does it's best to interpret the data in an FBX file, I cannot guarantee that it will read all FBX files, or all data within FBX files.**

Created by **Kozári László** in **2020.01.16**
