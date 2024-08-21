import 'package:chatapp/screens/register_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_button.dart';
import 'package:chatapp/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String emailText = '';
  String passwordText = '';

  // login method
  void login() async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signInWithEmailPassword(
          _emailController.text, _passwordController.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // image
            Container(
              height: 300,
              child: SvgPicture.asset(
                'assets/images/Chat.svg',
                semanticsLabel: 'Login',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // email
            CustomTextfield(
              controller: _emailController,
              labelText: 'Email',
              noIcon: true,
              onChanged: (value) {
                setState(() {
                  emailText = value;
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            // password
            CustomTextfield(
              controller: _passwordController,
              labelText: 'Password',
              onChanged: (value) {
                setState(() {
                  passwordText = value;
                });
              },
            ),

            SizedBox(
              height: 20,
            ),
            // button
            CustomButton(
              title: 'Login',
              color: appPrimary,
              onTap: () => login(),
              isDisabled: _emailController.text.isEmpty ||
                  _passwordController.text.isEmpty,
            ),
            SizedBox(
              height: 20,
            ),
            // Don't have an account?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Not a member? '),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ));
                  },
                  child: Text(
                    'Register now',
                    style: TextStyle(
                      color: appSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: getBody(),
    );
  }
}
