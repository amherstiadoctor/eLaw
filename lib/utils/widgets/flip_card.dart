import 'package:flutter/material.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard.dart';

//ignore: must_be_immutable
class FlipCard extends StatefulWidget {

  FlipCard({
    super.key,
    this.flashcardTitleController,
    this.frontInfoController,
    this.backInfoController,
    this.cardInfo,
    this.isView = false,
    this.isEdit = false,
  });
  TextEditingController? flashcardTitleController;
  TextEditingController? frontInfoController;
  TextEditingController? backInfoController;

  Flashcard? cardInfo;

  bool isView;
  bool isEdit;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
      child: GestureDetector(
        onTap: _toggleCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Transform(
              transform: Matrix4.rotationY(_animation.value * 3.14159),
              alignment: Alignment.center,
              child:
                  _animation.value < 0.5
                      ? _buildFrontCard(
                        widget.frontInfoController,
                        widget.isView,
                        widget.cardInfo?.frontInfo,
                      )
                      : Transform.scale(
                        scaleX: -1,
                        scaleY: 1,
                        child: _buildBackCard(
                          widget.backInfoController,
                          widget.isView,
                          widget.cardInfo?.backInfo,
                        ),
                      ),
            ),
        ),
      ),
    );
}

Widget _buildFrontCard(
  TextEditingController? controller,
  bool isView,
  String? info,
) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    width: 300,
    height: 500,
    decoration: BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.primaryShade),
    ),
    alignment: Alignment.center,
    child:
        isView
            ? Text(
              info ?? "Front",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
              textAlign: TextAlign.center,
            )
            : TextFormField(
              controller: controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Front Info",
                hintText: "Enter front info",
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.red),
                ),
              ),
              maxLines: 10,
              validator: (value) => value!.isEmpty ? "Enter info" : null,
              textInputAction: TextInputAction.next,
            ),
  );

Widget _buildBackCard(
  TextEditingController? controller,
  bool isView,
  String? info,
) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    width: 300,
    height: 500,
    decoration: BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.primaryShade),
    ),
    alignment: Alignment.center,
    child:
        isView
            ? Text(
              info ?? "Back",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
              textAlign: TextAlign.center,
            )
            : TextFormField(
              controller: controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Back Info",
                hintText: "Back front info",

                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.red),
                ),
              ),
              maxLines: 10,
              validator: (value) => value!.isEmpty ? "Enter info" : null,
              textInputAction: TextInputAction.next,
            ),
  );
