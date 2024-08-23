import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String UserId;

  const CustomChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.UserId,
  });

  // show options
  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // report message button
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _reportContent(context, messageId, userId);
                },
              ),

              // block user button
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Block'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId);
                },
              ),

              // cancel button
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // report message
  void _reportContent(BuildContext context, String messageId, String UserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Message'),
        content: Text('Are you sure you want to report this message?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          // report button
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, UserId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Message Reported',
                  style: TextStyle(color: appWhite),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ));
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  // block user
  void _blockUser(BuildContext context, String UserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to block this user?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          // report button
          TextButton(
            onPressed: () {
              ChatService().blockUser(UserId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'User Blocked',
                  style: TextStyle(color: appWhite),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ));
            },
            child: Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // show timestamp
      },
      onLongPress: () {
        if (!isCurrentUser) {
          // show options
          _showOptions(context, messageId, UserId);
        }
      },
      child: Container(
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
      ),
    );
  }
}
