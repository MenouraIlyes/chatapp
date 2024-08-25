import 'package:chatapp/screens/edit_profile_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_button.dart';
import 'package:chatapp/widgets/custom_profile_menu_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatapp/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text('No user logged in'));
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('User data not found'));
              }

              final userDoc = snapshot.data!;
              final userName = userDoc['name'] ?? 'No Name';
              final imageUrl = userDoc['profilePicture'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section
                  Stack(
                    children: [
                      Container(
                        height: 270,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6.0,
                              offset: Offset(0.0, 2.0),
                            ),
                          ],
                        ),
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
                      Column(
                        children: [
                          // Profile pic
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: imageUrl != ''
                                          ? Image.network(imageUrl)
                                          : Image.asset(
                                              'assets/images/default_pfp.png'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // User Name
                          Text(
                            userName,
                            style: TextStyle(
                              color: appWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Messages
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: appWhite,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_sharp,
                                  color: appPrimary,
                                ),
                              ),
                              // Call
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: appWhite,
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: appPrimary,
                                ),
                              ),
                              // Video
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: appWhite,
                                ),
                                child: Icon(
                                  Icons.videocam,
                                  color: appPrimary,
                                ),
                              ),
                              // More
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: appWhite,
                                ),
                                child: Icon(
                                  Icons.more_horiz,
                                  color: appPrimary,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),

                  // Bottom section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          // Your profile
                          CustomProfileMenuWidget(
                            icon: Icons.person,
                            title: 'Your Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          // Settings
                          CustomProfileMenuWidget(
                            icon: Icons.settings,
                            title: 'Settings',
                            onTap: () {},
                          ),
                          SizedBox(height: 10),
                          // Support
                          CustomProfileMenuWidget(
                            icon: Icons.support,
                            title: 'Support',
                            onTap: () {},
                          ),
                          SizedBox(height: 180),
                          // Logout button
                          CustomButton(
                            color: Colors.red,
                            isDisabled: false,
                            onTap: () async {
                              bool shouldSignOut =
                                  await _confirmSignOut(context);
                              if (shouldSignOut) {
                                await _authService.signOut(context);
                              }
                            },
                            title: 'LOGOUT',
                            icon: Icons.logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<bool> _confirmSignOut(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: appWhite,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            SizedBox(height: 5),
            Text('Are you sure you want to log out?'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: CustomButton(
                    title: 'Cancel',
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    isDisabled: false,
                    color: Colors.grey[500]!,
                    icon: Icons.cancel_sharp,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: CustomButton(
                    title: 'Yes, Logout',
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    isDisabled: false,
                    color: Colors.red,
                    icon: Icons.logout,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
