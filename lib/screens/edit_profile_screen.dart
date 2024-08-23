import 'dart:io';

import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_button.dart';
import 'package:chatapp/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _imageUrl;
  String? userName;
  String? email;
  String? phoneNumber;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // method to pick image and upload it to firebase
  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      isLoading = true;
    });
    if (image != null) {
      final User? user = _auth.currentUser;
      final String uid = user!.uid;
      final Reference storageRef =
          _storage.ref().child('profile_pictures/$uid');

      // Delete the existing profile picture if it exists
      try {
        await storageRef.delete();
      } catch (e) {}

      // Upload the new image to Firebase Storage
      await storageRef.putFile(File(image.path));
      _imageUrl = await storageRef.getDownloadURL();

      // Update Firestore with the new image URL
      await _firestore.collection('Users').doc(uid).set({
        'profilePicture': _imageUrl,
      }, SetOptions(merge: true));

      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to get the current user infos
  Future<void> _loadCurrentUser() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        userName = userDoc['name'];
        email = userDoc['email'];
        _imageUrl = userDoc['profilePicture'];
      });
    }
  }

  Widget getBody(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _phoneNumberController = TextEditingController();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Stack(children: [
            Container(
              height: 200,
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
                Stack(
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 35),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: appWhite,
                          size: 30,
                        ),
                      ),
                    ),
                    // profile pic
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
                                child: _imageUrl != null
                                    ? Image.network(_imageUrl!)
                                    : Image.asset(
                                        'assets/images/default_pfp.png'),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // edit pen
                    Positioned(
                      right: 140,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => _pickAndUploadImage(),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: appPrimary,
                          ),
                          child: const Icon(
                            Icons.mode,
                            color: appWhite,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),

          // bottom section
          Padding(
            padding: EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Account Informations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              // Name
              CustomTextfield(
                labelText: 'Name',
                controller: _nameController..text = userName ?? 'Loading...',
                noIcon: true,
              ),
              SizedBox(
                height: 20,
              ),
              // Email
              CustomTextfield(
                controller: _emailController..text = email ?? 'Loading...',
                labelText: "Email",
                noIcon: true,
              ),
              SizedBox(
                height: 20,
              ),

              // Phone Number
              CustomTextfield(
                controller: _phoneNumberController..text = phoneNumber ?? '',
                labelText: "Phone Number",
                noIcon: true,
              ),
              SizedBox(
                height: 20,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 1.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, -1.0),
          )
        ]),
        child: BottomAppBar(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          notchMargin: 0,
          color: appWhite,
          surfaceTintColor: appWhite,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
                left: 5,
              ),
              child: Column(
                children: [
                  // Submit button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: CustomButton(
                      color: appPrimary,
                      title: 'Update Profile',
                      isDisabled: false,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
      body: getBody(context),
    );
  }
}
