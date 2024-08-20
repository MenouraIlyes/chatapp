import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_search_bar.dart';
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
          padding: EdgeInsets.zero,
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
                  receiverName: userData['name'],
                ),
              ));
        },
        username: userData['name'],
      );
    } else {
      return Container();
    }
  }

  Widget getBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section
        Stack(children: [
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    offset: Offset(0.0, 2.0),
                  ),
                ]),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // profile pic, name
          Row(
            children: [
              // profile pic
              Padding(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                ),
                child: Container(
                  height: 80,
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset('assets/images/logo4.png'),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),

              // good morning + name
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Ilyes Menoura',
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // search bar
          Padding(
            padding: const EdgeInsets.only(top: 160, right: 20, left: 20),
            child: CustomSearchBar(
              hintField: 'Search',
              backgroundColor: appWhite,
            ),
          )
        ]),

        // bottom section
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chats
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    // manage
                    Text(
                      'Manage',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: appSecondary),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                // Messages list
                Expanded(child: _buildUserList(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: getBody(context),
    );
  }
}
