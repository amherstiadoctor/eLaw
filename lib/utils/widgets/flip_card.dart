import 'package:flutter/material.dart';
import 'package:sp_code/config/theme.dart';

//ignore: must_be_immutable
class FlipCard extends StatefulWidget {
  TextEditingController? flashcardTitleController;
  TextEditingController? frontInfoController;
  TextEditingController? backInfoController;

  Map<String, dynamic>? cardInfo;

  bool isView;
  bool isEdit;

  FlipCard({
    super.key,
    this.flashcardTitleController,
    this.frontInfoController,
    this.backInfoController,
    this.cardInfo,
    this.isView = false,
    this.isEdit = false,
  });

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
      duration: Duration(milliseconds: 600),
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
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _toggleCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.rotationY(_animation.value * 3.14159),
              alignment: Alignment.center,
              child:
                  _animation.value < 0.5
                      ? _buildFrontCard(
                        widget.frontInfoController,
                        widget.isView,
                        widget.cardInfo!['frontInfo'],
                      )
                      : Transform.scale(
                        scaleX: -1,
                        scaleY: 1,
                        child: _buildBackCard(),
                      ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildFrontCard(
  TextEditingController? controller,
  bool isView,
  String info,
) {
  return Container(
    width: 300,
    height: 500,
    decoration: BoxDecoration(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child:
        isView
            ? Text(
              info,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            )
            : controller != null
            ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Front Info",
                hintText: "Enter info",
                prefixIcon: Icon(
                  Icons.question_answer,
                  color: AppTheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter info";
                }
                return null;
              },
            )
            : Text(
              "Front",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
  );
}

Widget _buildBackCard() {
  return Container(
    width: 300,
    height: 500,
    decoration: BoxDecoration(
      color: AppTheme.secondary,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: Text(
      "Back",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.white,
      ),
    ),
  );
}
