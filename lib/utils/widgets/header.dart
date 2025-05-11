import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.title,
    this.color,
    this.has3rdIcon = false,
    this.hasBackButton = false,
    this.onButtonPress,
    this.hasRequests = false,
  });
  final String title;
  final Color? color;
  final bool? has3rdIcon;
  final bool? hasBackButton;
  final Function()? onButtonPress;
  final bool? hasRequests;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
    child: Container(
      color: Colors.transparent,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.hasBackButton!
              ? InkWell(
                child: Icon(
                  Icons.arrow_back,
                  color: widget.color ?? AppTheme.black,
                  size: 30,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
              : Container(width: 30.responsiveW),
          Text(
            widget.title.isEmpty ? '' : widget.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: widget.color ?? AppTheme.text,
            ),
          ),
          widget.has3rdIcon!
              ? IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 28,
                      color: widget.color ?? AppTheme.white,
                    ),
                    widget.hasRequests!
                        ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                          ),
                        )
                        : Container(),
                  ],
                ),
                onPressed: widget.onButtonPress,
              )
              : Container(width: 30.responsiveW),
        ],
      ),
    ),
  );
}
