import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomUserTile extends StatelessWidget {
  final String username;
  final void Function()? onTap;

  const CustomUserTile({
    super.key,
    required this.username,
    required this.onTap,
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
            color: appInversePrimary,
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
                    child: Image.asset('assets/images/logo4.png'),
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

                        // message
                        Text(
                          'Ok!',
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
                  'Today, 12:25',
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
