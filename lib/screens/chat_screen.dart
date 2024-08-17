import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/shared/colors.dart';
import 'package:chatapp/widgets/custom_chat_bubble.dart';
import 'package:chatapp/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // message controller
  final TextEditingController _messageController = TextEditingController();

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  // chat & auth service
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // add a listner to the focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so the keyboard has time to showup

        // calculate space then scroll down
        Future.delayed(Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // wait for the listview to be built, then scroll to bottom
    Future.delayed(Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    super.dispose();
    myFocusNode.dispose();
    _messageController.dispose();
  }

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      // clear the controller
      _messageController.clear();
    }

    // scroll down after sending of each message
    scrollDown();
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: appSecondary,
            ),
          );
        }

        // return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map(
                (doc) => _buildMessageListItem(doc),
              )
              .toList(),
        );
      },
    );
  }

  // message list item
  Widget _buildMessageListItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // get current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // align messages to the right if the sender is current user, else to the left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: CustomChatBubble(
        message: data['message'],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

  // build user input
  Widget _buildUserInput() {
    return Row(
      children: [
        // textfield
        Expanded(
          child: CustomTextfield(
            controller: _messageController,
            labelText: "Type a message",
            noIcon: true,
            focusNode: myFocusNode,
          ),
        ),

        // send button
        IconButton(
          icon: Icon(
            Icons.send,
            color: appSecondary,
          ),
          onPressed: sendMessage,
        ),
      ],
    );
  }

  Widget getBody() {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          // display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          SizedBox(
            height: 10,
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
          style: TextStyle(color: appWhite),
        ),
        centerTitle: true,
        backgroundColor: appPrimary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: appWhite,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: getBody(),
    );
  }
}
