import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool isDisabled;
  final Color color;
  final IconData? icon;
  final String title;
  final Function()? onTap;

  const CustomButton({
    super.key,
    required this.title,
    required this.isDisabled,
    required this.onTap,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: size.width,
        height: 45.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[400] : color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(17.5),
          boxShadow: [
            BoxShadow(
              color: appPrimary.withOpacity(0.5),
              spreadRadius: 0.0,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // icon
          if (icon != null) // Check if the icon is provided
            Icon(
              icon,
              color: appWhite,
            ),
          if (icon != null) const SizedBox(width: 8.0),
          // title
          Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: appWhite,
            ),
          ),
        ]),
      ),
    );
  }
}
