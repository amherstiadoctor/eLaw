part of 'responsive_sizer.dart';

typedef ResponsiveBuilder = Widget Function(BuildContext context);

class Responsive extends StatelessWidget {
  const Responsive({super.key, required this.builder});
  final ResponsiveBuilder builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => OrientationBuilder(
          builder: (context, orientation) {
            ResponsiveUtil.setScreenSize(constraints, orientation);
            return builder(context);
          },
        ),
    );
}
