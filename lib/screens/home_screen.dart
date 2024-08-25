import 'package:chatapp/providers/last_message_provider.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:chatapp/screens/blocked_users_screen.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_placeholder.dart';
import 'package:chatapp/widgets/custom_search_bar.dart';
import 'package:chatapp/widgets/custom_user_tile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/providers/chat_service_provider.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataSnapshot = ref.watch(userDataProvider);
    final pageIndex = ref.watch(pageIndexProvider);

    String? userName;
    String? imageUrl;
    bool isLoading = userDataSnapshot.isLoading;

    if (!isLoading && userDataSnapshot.value != null) {
      final userData = userDataSnapshot.value!.data();
      userName = userData?['name'];
      imageUrl = userData?['profilePicture'];
    }

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
          ref.read(pageIndexProvider.notifier).state = index;
        },
      ),
      body: _buildPage(pageIndex, ref, context, userName, imageUrl, isLoading),
    );
  }

  Widget _buildPage(int pageIndex, WidgetRef ref, BuildContext context,
      String? userName, String? imageUrl, bool isLoading) {
    switch (pageIndex) {
      case 1:
        return ProfileScreen();
      case 0:
      default:
        return _buildChatScreen(context, ref, userName, imageUrl, isLoading);
    }
  }

  Widget _buildChatScreen(BuildContext context, WidgetRef ref, String? userName,
      String? imageUrl, bool isLoading) {
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
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl)
                            : Image.asset('assets/images/default_pfp.png'),
                      ),
                    ),
                    if (isLoading)
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
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
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    // user name
                    Text(
                      userName ?? 'Loading...',
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 170, right: 20, left: 20),
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
                Expanded(child: _buildUserList(context, ref)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(BuildContext context, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);
    final user = ref.watch(userProvider).asData?.value;

    return StreamBuilder(
      stream: chatService.getUsersSteamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 8, // Number of placeholder items
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // Placeholder for profile picture
                    CustomPlaceholder(
                      height: 60,
                      width: 60,
                      borderRadius: 30,
                    ),
                    const SizedBox(width: 16),
                    // Placeholder for text and timestamp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomPlaceholder(
                            height: 20,
                            width: 150,
                          ),
                          const SizedBox(height: 8),
                          CustomPlaceholder(
                            height: 16,
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: snapshot.data!
              .map<Widget>(
                (userData) => _buildUserListItem(userData, context, ref),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context, WidgetRef ref) {
    final currentUserEmail = ref.watch(userProvider).asData?.value?.email;

    if (userData["email"] == null ||
        currentUserEmail == null ||
        userData["email"] == currentUserEmail) {
      return Container();
    }

    final lastMessageSnapshot = ref.watch(lastMessageProvider(userData['uid']));

    return lastMessageSnapshot.when(
      data: (lastMessageData) {
        String lastMessage = lastMessageData?['message'] ?? 'No messages yet';
        String formattedTimestamp = '';

        if (lastMessageData?['timestamp'] != null) {
          formattedTimestamp = DateFormat('EEEE, HH:mm')
              .format(lastMessageData!['timestamp'].toDate());
        }

        return CustomUserTile(
          username: userData['name'] ?? 'Unknown User',
          lastMessage: lastMessage,
          timestamp: formattedTimestamp,
          profilePicture: userData['profilePicture'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiverEmail: userData['email'],
                  receiverID: userData['uid'],
                  receiverName: userData['name'],
                ),
              ),
            );
          },
        );
      },
      loading: () => CustomUserTile(
        username: userData['name'] ?? 'Unknown User',
        lastMessage: 'Loading...',
        timestamp: '',
        onTap: () {},
      ),
      error: (_, __) => CustomUserTile(
        username: userData['name'] ?? 'Unknown User',
        lastMessage: 'Error loading message',
        timestamp: '',
        onTap: () {},
      ),
    );
  }
}
