import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool endIcon;
  final Color? textColor;

  const CustomProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.endIcon = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: appSecondary.withOpacity(0.8),
        ),
        child: Icon(
          icon,
          color: appWhite,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: appSecondary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.arrow_right_alt,
                color: appSecondary,
              ),
            )
          : null,
    );
  }
}
