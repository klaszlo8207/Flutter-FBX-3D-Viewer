/// Copyright (C) 2015 Brendan Duncan. All rights reserved.

class FbxFrameRate {
  static const int DEFAULT = 0;
  static const int FPS_120 = 1;
  static const int FPS_100 = 2;
  static const int FPS_60 = 3;
  static const int FPS_50 = 4;
  static const int FPS_48 = 5;
  static const int FPS_30 = 6;
  static const int FPS_30_DROP = 7;
  static const int NTSC_DROP_FRAME = 8;
  static const int NTSC_FULL_FRAME = 9;
  static const int PAL = 10;
  static const int FPS_24 = 11;
  static const int FPS_1000 = 12;
  static const int FILM_FULL_FRAME = 13;
  static const int CUSTOM = 14;
  static const int FPS_96 = 15;
  static const int FPS_72 = 16;
  static const int FPS_59_DOT_94 = 17;

  static double timeToFrame(int timeValue, int frameRate) {
    return (timeValue / 1924423250.0);
  }

  static double timeToSeconds(int timeValue, int frameRate) {
    return frameToSeconds(timeToFrame(timeValue, frameRate), frameRate);
  }

  static double frameToSeconds(double frame, int frameRate) {
    switch (frameRate) {
      case FPS_24:
        return frame / 24.0;
    }
    return frame;
  }
}
