import 'package:chatapp/screens/blocked_users_screen.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_search_bar.dart';
import 'package:chatapp/widgets/custom_user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        _userName = userDoc['name'];
      });
    }
  }

  Widget pageIndex(BuildContext context) {
    if (_page == 0) {
      return getBody(context);
    } else if (_page == 1) {
      return ProfileScreen();
    } else {
      return Container();
    }
  }

  // build a list of users except the current logged in user
  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getUsersSteamExcludingBlocked(),
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
                (userData) =>
                    _buildUserListItem(userData, context, _authService),
              )
              .toList(),
        );
      },
    );
  }

  // individual list tile for each user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context,
      AuthService authService) {
    final currentUserEmail = authService.getCurrentUser()?.email;

    // Skip if the user data or email is null or the user is the current user
    if (userData["email"] == null ||
        currentUserEmail == null ||
        userData["email"] == currentUserEmail) {
      return Container();
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _chatService.getLastMessageStream(
          authService.getCurrentUser()!.uid, userData['uid']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomUserTile(
            username: userData['name'] ?? 'Unknown User',
            lastMessage: 'Loading...',
            timestamp: '',
            onTap: () {},
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return CustomUserTile(
            username: userData['name'] ?? 'Unknown User',
            lastMessage: 'No messages yet',
            timestamp: '',
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
          );
        }

        // Extract last message and timestamp from the snapshot
        Map<String, dynamic>? lastMessageData = snapshot.data;
        String lastMessage = lastMessageData?['message'] ?? 'No messages yet';
        String formattedTimestamp = '';

        if (lastMessageData?['timestamp'] != null) {
          final DateTime date =
              (lastMessageData!['timestamp'] as Timestamp).toDate();
          formattedTimestamp = DateFormat('EEEE, HH:mm').format(date);
        }

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
          username: userData['name'] ?? 'Unknown User',
          lastMessage: lastMessage,
          timestamp: formattedTimestamp.isNotEmpty
              ? formattedTimestamp
              : 'No timestamp',
        );
      },
    );
  }

  Widget getBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          Row(
            children: [
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
                    child: Image.asset('assets/images/default_pfp.png'),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
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

                    // user name
                    Text(
                      _userName ?? 'Loading...',
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
          Padding(
            padding: const EdgeInsets.only(top: 160, right: 20, left: 20),
            child: CustomSearchBar(
              hintField: 'Search',
              backgroundColor: appWhite,
            ),
          )
        ]),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlockedUsersScreen(),
                            ));
                      },
                      child: Text(
                        'Manage',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: appSecondary),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
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
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        backgroundColor: appSecondary,
        color: appWhite,
        buttonBackgroundColor: appWhite,
        items: <Widget>[
          Icon(
            Icons.chat,
            size: 30,
            color: appPrimary,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: appPrimary,
          ),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      body: pageIndex(context),
    );
  }
}
