import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_user_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() {
    // auth service
    final authService = AuthService();

    try {
      authService.signOut(context);
    } catch (e) {
      print(e.toString());
    }
  }

  // build a list of users except the current logged in user
  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getUsersSteam(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: appSecondary,
          ));
        }

        // return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) => _buildUserListItem(userData, context),
              )
              .toList(),
        );
      },
    );
  }

  // individual list tile for each user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      // display all users except current user
      return CustomUserTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiverEmail: userData['email'],
                  receiverID: userData['uid'],
                ),
              ));
        },
        username: userData['email'],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appPrimary,
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(color: appWhite),
        ),
        actions: [
          // logout button
          IconButton(
            icon: Icon(
              Icons.logout,
              color: appWhite,
            ),
            onPressed: logout,
          )
        ],
      ),
      body: _buildUserList(context),
    );
  }
}
