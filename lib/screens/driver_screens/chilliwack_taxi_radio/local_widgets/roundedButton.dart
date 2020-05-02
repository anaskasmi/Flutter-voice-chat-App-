import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final double iconSize;
  final double buttonSize;
  final Color iconColor;
  final Color buttonColor;
  final IconData icon;
  RoundedButton(
      {this.iconSize,
      this.buttonSize,
      this.buttonColor,
      this.iconColor,
      this.icon});
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        child: Icon(
          this.icon,
          color: iconColor,
          size: iconSize,
        ),
        height: buttonSize,
        width: buttonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: buttonColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(1.1, 4.0), //(x,y)
              blurRadius: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
