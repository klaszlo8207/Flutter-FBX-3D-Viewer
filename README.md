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

**zoom**: Initial zoom.

**showInfo**: Show infos like FPS, and vertices.

**rotateX**: Animating the object with a rotateX.

**rotateY**: Animating the object with a rotateY.

**showWireframe**: Show the wireframe.

**wireframeColor**: Color of the wireframe.

**initialAngles**: Initial model angles.

## Convert an FBX binary file to an FBX ASCII file that can this library handle

1, First step is to download an animated/rigged fbx binary file from the net:

https://www.turbosquid.com/3d-models/free-female-character-rigged-biped-3d-model/569036

Lets see this model. (you will download **Mixamo-Joan_InjuredWalkAnimation.fbx  Autodesk FBX  - 4.22 MB**)

2, Second is to load that modell with **AUTODESK MotionBuilder 2020**

You just drop you file to your MotionBuilder then FBX Open -> mixamo.com

3, 
**Python Tools -> FBX Export on the MotionBuilder**

FBX Version: FBX 2014/2015 -> Export

SAVE -> .fbx (ASCII)

**Embed medias checked only**

**Save options:**

**Remove: (Settings)**

Base Cameras

Camera switchers

Current camera

Global Lighting

Transport

**Remove: (Scene)**

Cameras (all)

Textures (all)

Video

4, SAVE

Now if everything is went good in the fbx file header you can see this: **; FBX 7.4.0 project file**

## Limits

**FBX is a closed format, so while this library does it's best to interpret the data in an FBX file, I cannot guarantee that it will read all FBX files, or all data within FBX files.**

**No texture**

**Please don't use this library with a lot of vertices/polygons. Speed will be very low on huge point count.**

Normal speed will be on an fbx that is **max 3000 vertices**. (**Becuse it is draw with the CPU not on the GPU**)

## Author

**Kozári László** in **2020.01.16**

## License

Licensed under the Apache License, Version 2.0 (the "License")

