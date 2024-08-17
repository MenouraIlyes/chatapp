import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomUserTile extends StatelessWidget {
  final String username;
  final void Function()? onTap;

  const CustomUserTile({
    super.key,
    required this.username,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: appSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // icon
                Icon(
                  Icons.person,
                  color: appWhite,
                ),
                SizedBox(
                  width: 15,
                ),
                // username
                Text(
                  username,
                  style: TextStyle(
                    color: appWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
