import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';

class Header extends StatefulWidget {
  Header({
    super.key,
    required this.title,
    this.color,
    this.has3rdIcon = false,
    this.hasBackButton = false,
  });
  final String title;
  final Color? color;
  final bool? has3rdIcon;
  final bool? hasBackButton;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
      child: Container(
        color: Colors.transparent,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.black,
                size: 30,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            Text(
              widget.title.isEmpty ? '' : widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.color ?? AppTheme.text,
              ),
            ),
            const Spacer(),
            widget.has3rdIcon!
                ? Icon(Icons.settings_rounded, color: AppTheme.white, size: 40)
                : Container(width: 50.responsiveW),
          ],
        ),
      ),
    );
  }
}
