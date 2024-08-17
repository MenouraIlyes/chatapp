import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_button.dart';
import 'package:chatapp/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String emailText = '';
  String passwordText = '';
  String confirmPasswordText = '';

  void register() async {
    // auth service
    final authService = AuthService();

    // try register
    if (_passwordController.text == _confirmPasswordController.text) {
      // password match
      try {
        await authService.signUpInwithEmailPassword(
            _emailController.text, _passwordController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      // password doesn't match
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Password doesn't match"),
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
            Container(
              height: 250,
              child: SvgPicture.asset(
                'assets/images/Sign_up.svg',
                semanticsLabel: 'signup',
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
            // Confirm password
            CustomTextfield(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              onChanged: (value) {
                setState(() {
                  confirmPasswordText = value;
                });
              },
            ),

            SizedBox(
              height: 20,
            ),
            // button
            CustomButton(
              title: 'Register',
              color: appPrimary,
              onTap: () => register(),
              isDisabled: _emailController.text.isEmpty ||
                  _passwordController.text.isEmpty,
            ),
            SizedBox(
              height: 20,
            ),
            // go back
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: appSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: getBody(),
    );
  }
}
