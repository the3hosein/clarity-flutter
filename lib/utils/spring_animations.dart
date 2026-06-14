import 'package:flutter/material.dart';

class SpringAnimation {
  static const snappy = Duration(milliseconds: 300);
  static const smooth = Duration(milliseconds: 400);
  static const gentle = Duration(milliseconds: 500);
  static const bouncy = Duration(milliseconds: 400);

  static Curve snappyCurve = const Cubic(0.175, 0.885, 0.32, 1.275);
  static Curve smoothCurve = const Cubic(0.25, 0.46, 0.45, 0.94);
  static Curve gentleCurve = const Cubic(0.215, 0.61, 0.355, 1);
  static Curve bouncyCurve = const Cubic(0.68, -0.55, 0.265, 1.55);
}
