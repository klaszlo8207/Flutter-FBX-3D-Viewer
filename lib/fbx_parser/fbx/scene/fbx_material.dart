/// Copyright (C) 2015 Brendan Duncan. All rights reserved.
import '../fbx_element.dart';
import 'fbx_object.dart';
import 'fbx_property.dart';
import 'fbx_scene.dart';
import 'package:vector_math/vector_math.dart';

class FbxMaterial extends FbxObject {
  FbxProperty shadingModel;
  // lambert
  FbxProperty ambientColor;
  FbxProperty diffuseColor;
  FbxProperty transparencyFactor;
  FbxProperty emissive;
  FbxProperty ambient;
  FbxProperty diffuse;
  FbxProperty opacity;
  // phong
  FbxProperty specular;
  FbxProperty specularFactor;
  FbxProperty shininess;
  FbxProperty reflection;
  FbxProperty reflectionFactor;

  FbxMaterial(int id, String name, FbxElement element, FbxScene scene)
    : super(id, name, 'Material', element, scene) {

    shadingModel = addProperty('ShadingModel', 'lambert');
    ambientColor = addProperty('AmbientColor', Vector3(0.0, 0.0, 0.0));
    diffuseColor = addProperty('DiffuseColor', Vector3(1.0, 1.0, 1.0));
    transparencyFactor = addProperty('TransparencyFactor', 1.0);
    emissive = addProperty('Emissive', Vector3(0.0, 0.0, 0.0));
    ambient = addProperty('Ambient', Vector3(0.0, 0.0, 0.0));
    diffuse = addProperty('Diffuse', Vector3(1.0, 1.0, 1.0));
    opacity = addProperty('Opacity', 1.0);
    specular = addProperty('Specular', Vector3(1.0, 1.0, 1.0));
    specularFactor = addProperty('SpecularFactor', 0.0);
    shininess = addProperty('Shininess', 1.0);
    reflection = addProperty('Reflection', Vector3(1.0, 1.0, 1.0));
    reflectionFactor = addProperty('ReflectionFactor', 0.0);

    for (final c in element.children) {
      if (c.id == 'ShadingModel') {
        shadingModel.value = c.getString(0);
      } else if (c.id == 'Properties70') {
        for (final p in c.children) {
          if (p.properties[0] == 'AmbientColor') {
            ambientColor.value = Vector3(p.getDouble(4), p.getDouble(5),
                                             p.getDouble(6));
          } else if (p.properties[0] == 'DiffuseColor') {
            diffuseColor.value = Vector3(p.getDouble(4), p.getDouble(5),
                                             p.getDouble(6));
          } else if (p.properties[0] == 'TransparencyFactor') {
            transparencyFactor.value = p.getDouble(4);
          } else if (p.properties[0] == 'Emissive') {
            emissive.value = Vector3(p.getDouble(4), p.getDouble(5),
                                         p.getDouble(6));
          } else if (p.properties[0] == 'Ambient') {
            ambient.value = Vector3(p.getDouble(4), p.getDouble(5),
                                        p.getDouble(6));
          } else if (p.properties[0] == 'Diffuse') {
            diffuse.value = Vector3(p.getDouble(4), p.getDouble(5),
                                        p.getDouble(6));
          } else if (p.properties[0] == 'Opacity') {
            opacity.value = p.getDouble(4);
          } else if (p.properties[0] == 'Specular') {
            specular.value = Vector3(p.getDouble(4), p.getDouble(5),
                                        p.getDouble(6));
          } else if (p.properties[0] == 'SpecularFactor') {
            specularFactor.value = p.getDouble(4);
          } else if (p.properties[0] == 'Shininess') {
            shininess.value = p.getDouble(4);
          } else if (p.properties[0] == 'Reflection') {
            reflection.value = Vector3(p.getDouble(4), p.getDouble(5),
                                        p.getDouble(6));
          } else if (p.properties[0] == 'ReflectionFactor') {
            reflectionFactor.value = p.getDouble(4);
          }
        }
      }
    }
  }
}
