import 'package:flutter/material.dart';
import 'package:sp_code/config/theme.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
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
    return Scaffold(
      appBar: AppBar(title: Text("Flashcards")),
      body: Center(
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
                        ? _buildFrontCard()
                        : Transform.scale(
                          scaleX: -1,
                          scaleY: 1,
                          child: _buildBackCard(),
                        ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildFrontCard() {
  return Container(
    width: 200,
    height: 300,
    decoration: BoxDecoration(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: Text(
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
    width: 200,
    height: 300,
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
