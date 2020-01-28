/// Copyright (C) 2015 Brendan Duncan. All rights reserved.

class FbxAnimKey {
  static const int INTERPOLATION_CONSTANT = 0;
  static const int INTERPOLATION_LINEAR = 1;
  static const int INTERPOLATION_CUBIC = 2;

  static const int WEIGHTED_NONE = 0;
  static const int WEIGHTED_RIGHT = 1;
  static const int WEIGHTED_NEXT_LEFT = 2;

  static const int CONSTANT_STANDARD = 0;
  static const int CONSTANT_NEXT = 1;

  int time;
  double value;
  int interpolation;

  FbxAnimKey(this.time, this.value, this.interpolation);

  @override
  String toString() => '<$time : $value>';
}

