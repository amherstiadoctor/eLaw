import 'package:app_tutorial/app_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';

class TutorialItemContent extends StatefulWidget {
  TutorialItemContent({
    super.key,
    required this.title,
    required this.content,
    this.color,
  });

  final String title;
  final String content;
  Color? color;

  @override
  State<TutorialItemContent> createState() => _TutorialItemContentState();
}

class _TutorialItemContentState extends State<TutorialItemContent> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          margin: EdgeInsets.only(top: 90.responsiveH),
          padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "TUTORIAL",
                style: TextStyle(color: widget.color ?? Colors.white),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.title,
                style: TextStyle(color: widget.color ?? Colors.white),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.content,
                textAlign: TextAlign.center,
                style: TextStyle(color: widget.color ?? Colors.white),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Tutorial.skipAll(context),
                    child: Text(
                      'Skip tutorial',
                      style: TextStyle(color: widget.color ?? Colors.white),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      'Next',
                      style: TextStyle(color: widget.color ?? Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
