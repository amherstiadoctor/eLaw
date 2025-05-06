import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';

const double smallFontSize = 12;
const double mediumFontSize = 16;

const double smallLineHeight = 16;
const double mediumLineHeight = 20;

const smallFontWeight = FontWeight.w600;
const mediumFontWeight = FontWeight.w700;

Map<String, dynamic> getStyleMap(
  String status, {
  Color? color,
  Color? background,
  required bool isEmptyBackground,
  String size = 'large',
  required BuildContext context,
}) {
  if (status == "active") {
    return {
      'background':
          isEmptyBackground ? AppTheme.white : background ?? AppTheme.black,
      'textStyle':
          size != 'small'
              ? TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    isEmptyBackground
                        ? AppTheme.black
                        : color ?? AppTheme.white,
              )
              : TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isEmptyBackground
                        ? AppTheme.black
                        : color ?? AppTheme.white,
              ),
    };
  }

  if (status == "inactive") {
    return {
      'background':
          isEmptyBackground ? AppTheme.white : background ?? AppTheme.grey2,
      'textStyle':
          size != 'small'
              ? TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    isEmptyBackground
                        ? AppTheme.grey2
                        : color ?? AppTheme.white,
              )
              : TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isEmptyBackground
                        ? AppTheme.grey2
                        : color ?? AppTheme.white,
              ),
    };
  }

  return {};
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    this.status = 'active',
    required this.text,
    required this.size,
    this.color,
    this.width = 278,
    this.onClick,
    this.icon,
    this.background,
    this.isEmptyBackground = false,
  }) : super(key: key);
  final String status;
  final String text;
  final Widget? icon;
  final Function? onClick;
  final String size;
  final double width;
  final Color? color;
  final Color? background;
  final bool isEmptyBackground;

  double? getWidth(final String size) {
    if (size == 'large') {
      return double.infinity;
    }
    if (size == 'medium') {
      return width;
    }
    if (size == 'small') {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double largeHeight = 48.responsiveW;
    final double iconMargin = 8.responsiveW;

    final mediumPadding = EdgeInsets.symmetric(vertical: 14.0.responsiveW);
    final smallPadding = EdgeInsets.symmetric(
      vertical: 8.0.responsiveW,
      horizontal: 12.0.responsiveW,
    );
    final emptyPadding = EdgeInsets.symmetric(
      vertical: 4.0.responsiveW,
      horizontal: 12.0.responsiveW,
    );

    final double mediumRadius = 16.responsiveW;
    final double smallRadius = 20.responsiveW;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (onClick != null) {
          onClick!();
        }
      },
      child:
          size == 'large'
              ? Container(
                width: getWidth(size),
                height: largeHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color:
                        !isEmptyBackground
                            ? getStyleMap(
                              status,
                              background: background,
                              context: context,
                              color: color,
                              isEmptyBackground: isEmptyBackground,
                            )['background']
                            : getStyleMap(
                              status,
                              background: background,
                              context: context,
                              color: color,
                              isEmptyBackground: isEmptyBackground,
                            )['textStyle'].color,
                  ),
                  color:
                      getStyleMap(
                        status,
                        background: background,
                        context: context,
                        color: color,
                        isEmptyBackground: isEmptyBackground,
                      )['background'],
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        textScaleFactor: 1.responsiveW,
                        style:
                            getStyleMap(
                              status,
                              background: background,
                              context: context,
                              color: color,
                              isEmptyBackground: isEmptyBackground,
                            )['textStyle'],
                      ),
                      if (icon != null) SizedBox(width: iconMargin),
                      if (icon != null) icon!,
                    ],
                  ),
                ),
              )
              : FittedBox(
                fit: BoxFit.fitWidth,
                child: Container(
                  padding:
                      size == 'medium'
                          ? mediumPadding
                          : isEmptyBackground
                          ? emptyPadding
                          : smallPadding,
                  width: getWidth(size),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color:
                          !isEmptyBackground
                              ? getStyleMap(
                                status,
                                background: background,
                                context: context,
                                color: color,
                                isEmptyBackground: isEmptyBackground,
                              )['background']
                              : getStyleMap(
                                status,
                                background: background,
                                context: context,
                                color: color,
                                isEmptyBackground: isEmptyBackground,
                              )['textStyle'].color,
                    ),
                    color:
                        getStyleMap(
                          status,
                          background: background,
                          context: context,
                          color: color,
                          isEmptyBackground: isEmptyBackground,
                        )['background'],
                    borderRadius: BorderRadius.all(
                      size == 'medium'
                          ? Radius.circular(mediumRadius)
                          : Radius.circular(smallRadius),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        textScaleFactor: 1.responsiveW,
                        style:
                            getStyleMap(
                              status,
                              background: background,
                              context: context,
                              color: color,
                              isEmptyBackground: isEmptyBackground,
                              size: size,
                            )['textStyle'],
                      ),
                      if (icon != null) SizedBox(width: iconMargin),
                      if (icon != null) icon!,
                    ],
                  ),
                ),
              ),
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton({
    Key? key,
    this.status = 'active',
    required this.text,
    this.onClick,
    this.icon,
    this.color,
    this.background,
    this.isEmptyBackground = false,
  }) : super(key: key);

  final String status;
  final String text;
  final Widget? icon;
  final Function? onClick;
  final Color? color;
  final Color? background;
  final bool isEmptyBackground;

  @override
  Widget build(BuildContext context) {
    return _Button(
      status: status,
      text: text,
      icon: icon,
      onClick: onClick,
      background: background,
      color: color,
      isEmptyBackground: isEmptyBackground,
      size: 'small',
    );
  }
}

class MediumButton extends StatelessWidget {
  const MediumButton({
    Key? key,
    this.status = 'active',
    required this.text,
    this.width = 278,
    this.onClick,
    this.icon,
    this.color,
    this.background,
    this.isEmptyBackground = false,
  }) : super(key: key);

  final String status;
  final String text;
  final Widget? icon;
  final Function? onClick;
  final double width;
  final Color? color;
  final bool isEmptyBackground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return _Button(
      status: status,
      text: text,
      icon: icon,
      width: width.responsiveW,
      onClick: onClick,
      background: background,
      color: color,
      isEmptyBackground: isEmptyBackground,
      size: 'medium',
    );
  }
}

class LargeButton extends StatelessWidget {
  const LargeButton({
    Key? key,
    this.status = 'active',
    required this.text,
    this.onClick,
    this.icon,
    this.color,
    this.background,
    this.isEmptyBackground = false,
  }) : super(key: key);

  final String status;
  final String text;
  final Widget? icon;
  final Function? onClick;
  final Color? color;
  final Color? background;
  final bool isEmptyBackground;

  @override
  Widget build(BuildContext context) {
    return _Button(
      status: status,
      text: text,
      icon: icon,
      onClick: onClick,
      background: background,
      color: color,
      isEmptyBackground: isEmptyBackground,
      size: 'large',
    );
  }
}
