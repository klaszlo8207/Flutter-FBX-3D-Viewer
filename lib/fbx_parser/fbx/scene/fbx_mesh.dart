/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import '../matrix_utils.dart';
import 'fbx_cluster.dart';
import 'fbx_display_mesh.dart';
import 'fbx_edge.dart';
import 'fbx_geometry.dart';
import 'fbx_layer.dart';
import 'fbx_layer_element.dart';
import 'fbx_mapping_mode.dart';
import 'fbx_node.dart';
import 'fbx_polygon.dart';
import 'fbx_pose.dart';
import 'fbx_reference_mode.dart';
import 'fbx_scene.dart';
import 'fbx_skin_deformer.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';

class FbxMesh extends FbxGeometry {
  List<Vector3> points;
  int polygonVertexCount = 0;
  List<FbxPolygon> polygons = [];
  List<FbxEdge> edges = [];
  List<FbxLayer> layers = [];
  List<FbxDisplayMesh> display = [];
  List clusterMap = <dynamic>[];

  FbxMesh(int id, FbxElement element, FbxScene scene) : super(id, '', 'Mesh', element, scene) {
    for (final c in element.children) {
      if (c.id == 'Vertices') {
        _loadPoints(c);
      } else if (c.id == 'PolygonVertexIndex') {
        _loadPolygons(c);
      } else if (c.id == 'Edges') {
        _loadEdges(c);
      } else if (c.id == 'LayerElementNormal') {
        _loadNormals(c);
      } else if (c.id == 'LayerElementUV') {
        _loadUvs(c);
      } else if (c.id == 'LayerElementTexture') {
        _loadTexture(c);
      }
    }
  }

  FbxLayer getLayer(int index) {
    while (layers.length <= index) {
      layers.add(null);
    }

    if (layers[index] == null) {
      layers[index] = FbxLayer();
    }

    return layers[index];
  }

  List<FbxSkinDeformer> get skinDeformer {
    return findConnectionsByType('Skin') as List<FbxSkinDeformer>;
  }

  List<FbxCluster> _getClusters() {
    final clusters = <FbxCluster>[];
    final skins = findConnectionsByType('Skin');
    for (final skin in skins) {
      final l = <FbxCluster>[];
      skin.findConnectionsByType('Cluster', l);
      for (var c in l) {
        if (c.indexes != null && c.weights != null) {
          clusters.add(c);
        }
      }
    }
    return clusters;
  }

  bool hasDeformedPoints() => _deformedPoints != null;

  List<Vector3> get deformedPoints {
    _deformedPoints ??= List<Vector3>(points.length);
    return _deformedPoints;
  }

  void computeDeformations() {
    final meshNode = getConnectedFrom(0) as FbxNode;
    if (meshNode == null) {
      return;
    }
    computeLinearBlendSkinning(meshNode);
    updateDisplayMesh();
  }

  void updateDisplayMesh() {
    var pts = _deformedPoints ?? points;
    if (_deformedPoints[0] == null) {
      pts = points;
    }

    final disp = display[0];
    for (var pi = 0, len = pts.length; pi < len; ++pi) {
      for (var vi = 0; vi < disp.pointMap[pi].length; ++vi) {
        final dpi = disp.pointMap[pi][vi];
        disp.points[dpi] = pts[pi].x;
        disp.points[dpi + 1] = pts[pi].y;
        disp.points[dpi + 2] = pts[pi].z;
      }
    }
  }

  Float32List computeSkinPalette([Float32List data]) {
    final meshNode = getConnectedFrom(0) as FbxNode;
    if (meshNode == null) {
      return null;
    }

    data ??= Float32List(_clusters.length * 16);

    final pose = scene.getPose(0);

    for (var i = 0, j = 0, len = _clusters.length; i < len; ++i) {
      final cluster = _clusters[i];
      final w = _getClusterMatrix(meshNode, cluster, pose);
      for (var k = 0; k < 16; ++k) {
        data[j++] = w.storage[k];
      }
    }

    return data;
  }

  void computeLinearBlendSkinning(FbxNode meshNode) {
    final outPoints = deformedPoints;
    final pose = scene.getPose(0);

    for (var pi = 0, len = points.length; pi < len; ++pi) {
      if (clusterMap[pi] == null || (clusterMap[pi] as List).isEmpty) {
        continue;
      }

      var sp = Vector3.zero();
      var p = points[pi];
      var weightSum = 0.0;

      var clusterMode = FbxCluster.NORMALIZE;

      for (var clusterWeight in clusterMap[pi]) {
        final cluster = clusterWeight[0] as FbxCluster;
        final weight = clusterWeight[1] as double;

        clusterMode = cluster.linkMode;

        final w = _getClusterMatrix(meshNode, cluster, pose);

        sp += ((w * p) as Vector3) * weight;

        weightSum += weight;
      }

      if (clusterMode == FbxCluster.NORMALIZE) {
        if (weightSum != 0.0) {
          sp /= weightSum;
        }
      } else if (clusterMode == FbxCluster.TOTAL_ONE) {
        sp += p * (1.0 - weightSum);
      }

      outPoints[pi] = sp;
    }
  }

  Matrix4 _getClusterMatrix(FbxNode meshNode, FbxCluster cluster, FbxPose pose) {
    final joint = cluster.getLink();

    var refGlobalInitPos;

    //TODO BUG1 was
    if (pose == null)
      refGlobalInitPos = new Matrix4.identity();
    else
      refGlobalInitPos = pose.getMatrix(meshNode);

    if (refGlobalInitPos == null) refGlobalInitPos = new Matrix4.identity();

    final refGlobalCurrentPos = meshNode.evalGlobalTransform();

    final clusterGlobalInitPos = inverseMat(cluster.transformLink);

    final clusterGlobalCurrentPos = joint.evalGlobalTransform();

    final clusterRelativeInitPos = (clusterGlobalInitPos * refGlobalInitPos) as Matrix4;

    final clusterRelativeCurrentPosInverse = (inverseMat(refGlobalCurrentPos) * clusterGlobalCurrentPos) as Matrix4;

    final vertexTransform = (clusterRelativeCurrentPosInverse * clusterRelativeInitPos) as Matrix4;

    return vertexTransform;
  }

  void generateClusterMap() {
    clusterMap = List<dynamic>(points.length);

    for (final cluster in _clusters) {
      if (cluster.indexes == null || cluster.weights == null) {
        continue;
      }

      for (var i = 0; i < cluster.indexes.length; ++i) {
        var pi = cluster.indexes[i];
        if (clusterMap[pi] == null) {
          clusterMap[pi] = <dynamic>[];
        }
        clusterMap[pi].add([cluster, cluster.weights[i]]);
      }
    }
  }

  void generateDisplayMeshes() {
    display = [];

    if (points == null) {
      return;
    }

    _clusters = _getClusters();
    generateClusterMap();

    final disp = FbxDisplayMesh();
    display.add(disp);

    var splitPolygonVerts = false;

    FbxLayer layer;
    FbxLayerElement<Vector3> normals;
    FbxLayerElement<Vector2> uvs;

    if (layers.isNotEmpty) {
      layer = layers[0];
    }

    if (layer != null && layer.hasNormals) {
      normals = layer.normals;
      if (normals.mappingMode != FbxMappingMode.ByControlPoint) {
        splitPolygonVerts = true;
      }
    }

    if (layer != null && layer.hasUvs) {
      uvs = layer.uvs;
      if (uvs.mappingMode != FbxMappingMode.ByControlPoint) {
        splitPolygonVerts = true;
      }
    }

    disp.pointMap = List<List<int>>(points.length);

    if (splitPolygonVerts) {
      var triCount = 0;
      var numPoints = 0;
      for (final poly in polygons) {
        triCount += poly.vertices.length - 2;
        numPoints += poly.vertices.length;
      }

      disp.numPoints = numPoints;
      disp.points = Float32List(numPoints * 3);
      disp.indices = Uint16List(triCount * 3);

      if (normals != null) {
        disp.normals = Float32List(disp.points.length);
      }

      if (uvs != null) {
        disp.uvs = Float32List(disp.points.length);
      }

      var pi = 0;
      var ni = 0;
      var ni2 = 0;
      var ti = 0;
      var ti2 = 0;

      for (final poly in polygons) {
        for (var vi = 0, len = poly.vertices.length; vi < len; ++vi, ++ni2, ++ti2) {
          var p1 = poly.vertices[vi];

          if (disp.pointMap[p1] == null) {
            disp.pointMap[p1] = <int>[];
          }
          disp.pointMap[p1].add(pi);

          disp.points[pi++] = points[p1].x;
          disp.points[pi++] = points[p1].y;
          disp.points[pi++] = points[p1].z;

          if (normals != null) {
            if (normals.mappingMode == FbxMappingMode.ByControlPoint) {
              ni2 = p1;
            }
            disp.normals[ni++] = normals[ni2].x;
            disp.normals[ni++] = normals[ni2].y;
            disp.normals[ni++] = normals[ni2].z;
          }

          if (uvs != null) {
            if (uvs.mappingMode == FbxMappingMode.ByControlPoint) {
              ti2 = p1;
            }
            if (ti2 < uvs.data.length) {
              disp.uvs[ti++] = uvs.data[ti2].x;
              disp.uvs[ti++] = uvs.data[ti2].y;
            }
          }
        }
      }

      pi = 0;
      var xi = 0;
      for (final poly in polygons) {
        for (var vi = 2, len = poly.vertices.length; vi < len; ++vi) {
          disp.indices[xi++] = pi;
          disp.indices[xi++] = pi + (vi - 1);
          disp.indices[xi++] = pi + vi;
        }
        pi += poly.vertices.length;
      }
    } else {
      disp.numPoints = points.length;
      disp.points = Float32List(points.length * 3);

      for (var xi = 0, pi = 0, len = points.length; xi < len; ++xi) {
        disp.pointMap[xi] = [pi];

        disp.points[pi++] = points[xi].x;
        disp.points[pi++] = points[xi].y;
        disp.points[pi++] = points[xi].z;
      }

      if (normals != null) {
        disp.normals = Float32List(disp.points.length);

        for (var vi = 0, ni = 0, len = normals.data.length; ni < len; ++ni) {
          disp.normals[vi++] = normals[ni].x;
          disp.normals[vi++] = normals[ni].y;
          disp.normals[vi++] = normals[ni].z;
        }
      }

      if (uvs != null) {
        disp.uvs = Float32List(points.length * 2);

        for (var vi = 0, ni = 0, len = uvs.data.length; ni < len; ++ni) {
          disp.uvs[vi++] = uvs[ni].x;
          disp.uvs[vi++] = uvs[ni].y;
        }
      }

      final verts = <int>[];

      for (final poly in polygons) {
        for (var vi = 2, len = poly.vertices.length; vi < len; ++vi) {
          verts.add(poly.vertices[0]);
          verts.add(poly.vertices[vi - 1]);
          verts.add(poly.vertices[vi]);
        }
      }

      disp.indices = Uint16List.fromList(verts);
    }

    if (disp.normals == null) {
      disp.generateSmoothNormals();
    }

    if (_clusters.isNotEmpty) {
      disp.skinWeights = Float32List(disp.numPoints * 4);
      disp.skinIndices = Float32List(disp.numPoints * 4);

      final count = Int32List(points.length);

      for (var ci = 0, len = _clusters.length; ci < len; ++ci) {
        final index = ci.toDouble();

        final cluster = _clusters[ci];

        for (var xi = 0, numPts = cluster.indexes.length; xi < numPts; ++xi) {
          final weight = cluster.weights[xi];
          final pi = cluster.indexes[xi];

          if (disp.pointMap[pi] != null) {
            for (var vi = 0, nv = disp.pointMap[pi].length; vi < nv; ++vi) {
              final pv = (disp.pointMap[pi][vi] ~/ 3) * 4;

              if (count[pi] > 3) {
                for (var cc = 0; cc < 4; ++cc) {
                  if (disp.skinWeights[pv + cc] < weight) {
                    disp.skinIndices[pv + cc] = index;
                    disp.skinWeights[pv + cc] = weight;
                    break;
                  }
                }
              } else {
                final wi = pv + count[pi];
                disp.skinIndices[wi] = index;
                disp.skinWeights[wi] = weight;
              }
            }
          }

          count[pi]++;
        }
      }

      //TODO disp uvs-en atmegyunk , rendezzuk index szerint
      Float32List newUvs = Float32List(disp.uvs.length);
      int j = 0;
      for (int index = 0; index < uvs.indexArray.length; index++) {
        final uvIndex = uvs.indexArray[index];
        final temp = uvs.data[uvIndex];
        newUvs[j++] = temp.x;
        newUvs[j++] = temp.y;
      }
      disp.uvs = newUvs;
    }
  }

  void _loadPoints(FbxElement e) {
    var p = ((e.properties.length == 1 && e.properties[0] is List) ? e.properties[0] : (e.children.length == 1) ? e.children[0].properties : e.properties) as List;

    points = List(p.length ~/ 3);

    for (var i = 0, j = 0, len = p.length; i < len; i += 3) {
      points[j++] = Vector3(toDouble(p[i]), toDouble(p[i + 1]), toDouble(p[i + 2]));
    }
  }

  void _loadPolygons(FbxElement e) {
    var p = ((e.properties.length == 1 && e.properties[0] is List) ? e.properties[0] : (e.children.length == 1) ? e.children[0].properties : e.properties) as List;

    polygonVertexCount = p.length;

    var polygonStart = 0;

    // Triangulate the mesh while we're parsing it.
    for (var i = 0, len = p.length; i < len; ++i) {
      var vi = toInt(p[i]);

      // negative index indicates the end of a polygon
      if (vi < 0) {
        vi = ~vi;

        final poly = FbxPolygon();
        polygons.add(poly);

        for (var xi = polygonStart; xi < i; ++xi) {
          poly.vertices.add(toInt(p[xi]));
        }
        poly.vertices.add(vi);

        polygonStart = i + 1;
      }
    }
  }

  void _loadEdges(FbxElement e) {
    /*var p = (e.properties.length == 1 && e.properties[0] is List) ? e.properties[0]
            : (e.children.length == 1) ? e.children[0].properties
            : e.properties;

    for (int ei = 0, len = p.length; ei < len; ei += 2) {
      int v1 = toInt(p[ei]);
      int v2 = toInt(p[ei + 1]);
      edges.add(FbxEdge(v1, v2));
    }*/
  }

  void _loadNormals(FbxElement e) {
    final layerIndex = toInt(e.properties[0]);
    final layer = getLayer(layerIndex);

    final normals = layer.normals;

    for (final c in e.children) {
      if (c.properties.isEmpty) {
        continue;
      }

      if (c.id == 'MappingInformationType') {
        normals.mappingMode = stringToMappingMode(c.properties[0] as String);
      } else if (c.id == 'ReferenceInformationType') {
        normals.referenceMode = stringToReferenceMode(c.properties[0] as String);
      } else if (c.id == 'Normals') {
        var p = ((c.properties.length == 1 && c.properties[0] is List) ? c.properties[0] : (c.children.length == 1) ? c.children[0].properties : c.properties) as List;

        normals.data = List<Vector3>(p.length ~/ 3);
        for (var i = 0, j = 0, len = p.length; i < len; i += 3) {
          normals.data[j++] = Vector3(toDouble(p[i]), toDouble(p[i + 1]), toDouble(p[i + 2]));
        }
      }
    }
  }

  void _loadUvs(FbxElement e) {
    final layerIndex = toInt(e.properties[0]);
    final layer = getLayer(layerIndex);

    final uvs = layer.uvs;

    for (final c in e.children) {
      var p = ((c.properties.length == 1 && c.properties[0] is List) ? c.properties[0] : (c.children.length == 1) ? c.children[0].properties : c.properties) as List;

      if (c.id == 'MappingInformationType') {
        uvs.mappingMode = stringToMappingMode(p[0] as String);
      } else if (c.id == 'ReferenceInformationType') {
        uvs.referenceMode = stringToReferenceMode(p[0] as String);
      } else if (c.id == 'UV' && p.isNotEmpty) {
        uvs.data = List<Vector2>(p.length ~/ 2);
        for (var i = 0, j = 0, len = p.length; i < len; i += 2) {
          uvs.data[j++] = Vector2(toDouble(p[i]), toDouble(p[i + 1]));
        }
      }
      //TODO UVIndex
      else if (c.id == 'UVIndex' && p.isNotEmpty) {
        uvs.indexArray = List<int>(p.length);
        for (var i = 0, j = 0, len = p.length; i < len; i++) {
          uvs.indexArray[j++] = toInt(p[i]);
        }
      }
    }
  }

  void _loadTexture(FbxElement e) {}

  List<Vector3> _deformedPoints;
  List<FbxCluster> _clusters = [];
}
