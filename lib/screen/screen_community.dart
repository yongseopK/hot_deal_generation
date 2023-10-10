import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_add_post.dart';
import 'package:hot_deal_generation/screen/screen_post_detail.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          child: ListView.builder(
            itemCount: 15, // 게시물 개수에 맞게 조정
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _navigateToPostDetail(context, index);
                },
                child: Card(
                  margin: const EdgeInsets.all(2.0),
                  child: ListTile(
                    leading: Image.asset(
                      'images/fifalogo.png', // 게시물 이미지
                      width: width * 0.1,
                      height: height * 0.1,
                    ),
                    title: Text(
                      '게시물 제목 $index', // 게시물 제목
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      '게시물 내용 $index', // 게시물 내용
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: loggedUser != null
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPost(),
                    ),
                  );
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add), // FAB에 아이콘 추가
              )
            : null,
      ),
    );
  }
}

void _navigateToPostDetail(BuildContext context, int postIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PostDetailPage(postIndex: postIndex),
    ),
  );
}
