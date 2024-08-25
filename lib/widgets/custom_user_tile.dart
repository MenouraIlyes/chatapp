import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomUserTile extends StatelessWidget {
  final String username;
  final void Function()? onTap;
  final String lastMessage;
  final String timestamp;
  final String? profilePicture;

  const CustomUserTile({
    super.key,
    required this.username,
    required this.onTap,
    this.lastMessage = '',
    this.timestamp = '',
    this.profilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: appWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Profile Pic
                Container(
                  height: 50,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: profilePicture != ''
                        ? Image.network(profilePicture!)
                        : Image.asset('assets/images/default_pfp.png'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // name
                        Text(
                          username,
                          style: TextStyle(
                            color: appPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // last message
                        Text(
                          lastMessage,
                          style: TextStyle(
                            color: appPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // timestamp
                Text(
                  timestamp,
                  style: TextStyle(
                    color: appPrimary,
                    fontWeight: FontWeight.w500,
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
