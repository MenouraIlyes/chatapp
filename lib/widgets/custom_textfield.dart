import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool noIcon;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.labelText,
    this.noIcon = false,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool isObsecure = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: isObsecure,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIconColor: appPrimary,
        labelStyle: TextStyle(color: appSecondary.withOpacity(0.5)),
        suffixIcon: widget.noIcon
            ? const SizedBox()
            : IconButton(
                onPressed: () {
                  setState(() {
                    isObsecure = !isObsecure;
                  });
                },
                icon: isObsecure
                    ? const Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
              ),
        contentPadding: EdgeInsets.all(15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
      ),
    );
  }
}
