part of 'responsive_sizer.dart';

extension ResponsiveExt on num {
  //calculates thge heigh depending on the device's width size
  double get responsiveW => this * ResponsiveUtil.widthRatio;
  double get responsiveH => this * ResponsiveUtil.heightRatio;
}
