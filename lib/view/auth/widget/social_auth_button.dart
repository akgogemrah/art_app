import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final double heightFactor;
  final double widthFactor;
  final Color iconColor;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;

  SocialAuthButton({
    required this.icon,
    this.heightFactor = 0.08,
    this.widthFactor = 0.4,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.white12,
    this.borderRadius = 10.0,
    this.borderColor = Colors.white54,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * heightFactor,
      width: screenSize.width * widthFactor,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
