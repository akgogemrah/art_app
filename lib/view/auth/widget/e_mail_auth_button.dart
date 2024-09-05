import 'package:flutter/material.dart';

class EmailAuthButton extends StatelessWidget {
  final String text;
  final double heightFactor;
  final double widthFactor;
  final double borderRadius;
  final List<Color> gradientColors;
  final TextStyle textStyle;

  EmailAuthButton({
    required this.text,
    this.heightFactor = 0.07,
    this.widthFactor = 1.0,
    this.borderRadius = 12.0,
    this.gradientColors = const [Colors.pink, Colors.purple],
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 20,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * heightFactor,
      width: screenSize.width * widthFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(colors: gradientColors),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}
