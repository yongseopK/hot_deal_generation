import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/chatting/chat/message.dart';
import 'package:hot_deal_generation/chatting/chat/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: loggedUser != null
              ? Container(
                  child: const Column(
                    children: [
                      Expanded(
                        child: Messages(),
                      ),
                      NewMessage(),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    "로그인을 해주세요",
                    style: GoogleFonts.doHyeon(fontSize: 30),
                  ),
                ),
        ),
      ),
    );
  }
}
