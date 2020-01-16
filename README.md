# Flutter FBX 3D Viewer

Flutter package for viewing FBX 3D animated files

**This library is experimental. Some FBX files, particularly older fbx files, may not load correctly. No guarantee is provided as FBX is a closed proprietary format.**

This library is based on the [dart_fbx](https://github.com/brendan-duncan/dart_fbx) library

![alt text](https://raw.githubusercontent.com/klaszlo8207/Flutter-FBX-3D-Viewer/master/pix/pic1.png "Pic1") ![alt text](https://raw.githubusercontent.com/klaszlo8207/Flutter-FBX-3D-Viewer/master/pix/pic2.png "Pic2") ![alt text](https://raw.githubusercontent.com/klaszlo8207/Flutter-FBX-3D-Viewer/master/pix/gif.gif "Gif")

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

## Properties

**path**: you can add an **asset path (fromAsset=true)** or you can add an **SD card path (fromAsset=false)**

**zoom**: How to zoom for the first time.

**showInfo**: Show infos like FPs, and vertices.

**rotateX**: Animating the object with a rotateX.

**rotateY**: Animating the object with a rotateY.

**showWireframe**: Show the wireframe.

**wireframeColor**: Color of the wireframe.

**initialAngles**: The initial model angles.

## Limits

**FBX is a closed format, so while this library does it's best to interpret the data in an FBX file, I cannot guarantee that it will read all FBX files, or all data within FBX files.**

## Author

**Kozári László** in **2020.01.16**

## License

Licensed under the Apache License, Version 2.0 (the "License")

