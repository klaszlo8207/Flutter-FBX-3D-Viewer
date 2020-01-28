/*
 * Copyright (C) 2015 Brendan Duncan. All rights reserved.
 */

class FbxElement {
  String id;
  List properties;
  List<FbxElement> children = [];

  FbxElement(this.id, [int propertyCount]) {
    if (propertyCount != null) {
      properties = List<dynamic>(propertyCount);
    } else {
      properties = <dynamic>[];
    }
  }

  String getString(int index) => properties[index].toString();

  int getInt(int index) => toInt(properties[index]);

  double getDouble(int index) => toDouble(properties[index]);

  double toDouble(dynamic x) =>
      x is String ? double.parse(x) :
      x is bool ? (x ? 1.0 : 0.0) :
      (x as num).toDouble();

  int toInt(dynamic x) =>
      x is String ? int.parse(x) :
      x is bool ? (x ? 1 : 0) :
      (x as num).toInt();
}
