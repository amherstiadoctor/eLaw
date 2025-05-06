part of responsive;

typedef ResponsiveBuilder = Widget Function(BuildContext context);

class Responsive extends StatelessWidget {
  const Responsive({Key? key, required this.builder}) : super(key: key);
  final ResponsiveBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            ResponsiveUtil.setScreenSize(constraints, orientation);
            return builder(context);
          },
        );
      },
    );
  }
}
