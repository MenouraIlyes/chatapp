import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const CustomChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? appPrimary : appSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        message,
        style: TextStyle(
          color: appWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
