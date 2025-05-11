part of 'responsive_sizer.dart';

const _iphone13ProWidth = 390;
const _iphone13ProHeight = 844;

class ResponsiveUtil {
  static late BoxConstraints _boxConstraints;

  static Orientation orientation = Orientation.portrait;

  static double height = _iphone13ProHeight.toDouble();

  static double width = _iphone13ProWidth.toDouble();

  static double widthRatio = 1;

  static double heightRatio = 1;

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    _boxConstraints = constraints;
    orientation = currentOrientation;

    if (orientation == Orientation.portrait) {
      width = _boxConstraints.maxWidth;
      height = _boxConstraints.maxHeight;
    } else {
      width = _boxConstraints.maxHeight;
      height = _boxConstraints.maxWidth;
    }
    widthRatio = _boxConstraints.maxWidth / _iphone13ProWidth;
    heightRatio = _boxConstraints.maxHeight / _iphone13ProHeight;
  }
}
