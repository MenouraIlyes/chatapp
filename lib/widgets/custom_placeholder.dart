import 'package:flutter/material.dart';

class CustomPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const CustomPlaceholder({
    Key? key,
    required this.height,
    required this.width,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
