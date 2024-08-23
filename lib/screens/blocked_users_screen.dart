import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_user_tile.dart';
import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatelessWidget {
  BlockedUsersScreen({super.key});

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Confirm Unblock dialogue
  void _confirmUnblock(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Unblock User"),
        content: Text("Are you sure you want to unblock this user?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          // unblock button
          TextButton(
            onPressed: () {
              _chatService.UnblockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'User Unblocked',
                  style: TextStyle(color: appWhite),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ));
            },
            child: Text('Unblock'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUsersList() {
    // get current user id
    final UserId = _authService.getCurrentUser()!.uid;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getBlockedUsersStream(UserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading blocked users'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: appSecondary,
            ),
          );
        }

        final blockedUsers = snapshot.data ?? [];

        // no users
        if (blockedUsers.isEmpty) {
          return Center(
            child: Text('No blocked users'),
          );
        }

        return ListView.builder(
          itemCount: blockedUsers.length,
          itemBuilder: (context, index) {
            final user = blockedUsers[index];
            return CustomUserTile(
              onTap: () {
                _confirmUnblock(context, user['uid']);
              },
              username: user['name'],
            );
          },
        );
      },
    );
  }

  Widget getBody() {
    return Column(
      children: [
        Expanded(
          child: _buildBlockedUsersList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: appWhite,
          ),
        ),
        backgroundColor: appPrimary,
        title: Text(
          'Blocked Users',
          style: TextStyle(
            color: appWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: getBody(),
    );
  }
}
