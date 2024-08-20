import 'package:chatapp/shared/colors.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    Key? key,
    required this.hintField,
    this.backgroundColor,
  }) : super(key: key);

  final String hintField;
  final Color? backgroundColor;

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search Icon
          Container(
            height: 40.0,
            width: 40.0,
            alignment: Alignment.center,
            child: Icon(
              Icons.search_rounded,
              color: appPrimary,
            ),
          ),

          // Search Field
          Flexible(
            child: Container(
              width: size.width,
              height: 32,
              alignment: Alignment.topCenter,
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 15),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: widget.hintField,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: appPrimary.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
