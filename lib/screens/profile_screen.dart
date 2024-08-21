import 'package:chatapp/screens/login_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_button.dart';
import 'package:chatapp/widgets/custom_profile_menu_widget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();

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

  Future<void> _handleSignOut(BuildContext context) async {
    bool shouldSignOut = await _confirmSignOut(context);
    if (shouldSignOut) {
      await _authService.signOut(context);
    }
  }

  Widget getBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section
        Stack(children: [
          Container(
            height: 250,
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
          Column(
            children: [
              // profile pic
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Container(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('assets/images/default_pfp.png'),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // User Name
              Text(
                'Ilyes Menoura',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // messages
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
                  // call
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
                      )),
                  // video
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
                      )),
                  // more
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
                      )),
                ],
              )
            ],
          ),
        ]),

        // bottom section
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                // your profile
                CustomProfileMenuWidget(
                  icon: Icons.person,
                  title: 'Your Profile',
                  onTap: () {},
                ),
                SizedBox(
                  height: 10,
                ),

                // settings
                CustomProfileMenuWidget(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {},
                ),
                SizedBox(
                  height: 10,
                ),

                // support
                CustomProfileMenuWidget(
                  icon: Icons.support,
                  title: 'Support',
                  onTap: () {},
                ),
                SizedBox(
                  height: 200,
                ),

                // logout button
                CustomButton(
                  color: Colors.red,
                  isDisabled: false,
                  onTap: () {
                    _handleSignOut(context);
                  },
                  title: 'LOGOUT',
                  icon: Icons.logout,
                )
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
      body: getBody(context),
    );
  }
}
