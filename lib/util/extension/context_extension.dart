import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double getHeight(double ratio) => MediaQuery.sizeOf(this).height * ratio;
  double getWidth(double ratio) => MediaQuery.sizeOf(this).width * ratio;

  Size get size => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get height => MediaQuery.sizeOf(this).height;

  bool get isAndroidPhone => Platform.isAndroid;

}