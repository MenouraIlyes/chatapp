import 'dart:io';

import 'package:chatapp/providers/user_data_provider.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_button.dart';
import 'package:chatapp/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isLoading = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();

    // Load user data once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = ref.read(userDataProvider).asData?.value?.data();
      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneNumberController.text = userData['phoneNumber'] ?? '';

        // Update StateProvider with user data
        ref.read(userDataStateProvider.notifier).state = userData;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

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
      final _imageUrl = await storageRef.getDownloadURL();

      // Update Firestore with the new image URL
      await _firestore.collection('Users').doc(uid).set({
        'profilePicture': _imageUrl,
      }, SetOptions(merge: true));

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsyncValue = ref.watch(userDataProvider);

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
      body: userDataAsyncValue.when(
        data: (userDoc) {
          final userData = userDoc?.data();
          final profilePicture = userData?['profilePicture'] ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                      child: profilePicture.isNotEmpty
                                          ? Image.network(profilePicture)
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Informations',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 40),
                        // Name
                        CustomTextfield(
                          labelText: 'Name',
                          controller: _nameController,
                          noIcon: true,
                        ),
                        SizedBox(height: 20),
                        // Email
                        CustomTextfield(
                          labelText: 'Email',
                          controller: _emailController,
                          noIcon: true,
                        ),
                        SizedBox(height: 20),
                        // Phone Number
                        CustomTextfield(
                          labelText: 'Phone Number',
                          controller: _phoneNumberController,
                          noIcon: true,
                        ),
                      ]),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
