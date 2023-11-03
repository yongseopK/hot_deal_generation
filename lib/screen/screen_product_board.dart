// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_add_post.dart';

class ProductBoard extends StatefulWidget {
  const ProductBoard({Key? key, this.data}) : super(key: key);

  final dynamic data;

  static const Map<String, String> dataToTitle = {
    "computer": "컴퓨터",
    "labtop": "노트북",
    "mobile": "스마트폰",
    "tablet": "태블릿",
    "wearable": "웨어러블",
    "mouse": "마우스",
    "keyboard": "키보드",
    "soundSystem": "음향기기",
    "cpu": "CPU",
    "gpu": "그래픽 카드",
    "ram": "램",
    "storage": "저장장치",
    "power": "파워",
    "case": "케이스",
  };

  @override
  State<ProductBoard> createState() => _ProductBoardState();
}

class _ProductBoardState extends State<ProductBoard> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

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
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final title = ProductBoard.dataToTitle[widget.data];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: title != null ? Text(title) : null,
      ),
      floatingActionButton: loggedUser != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPost(),
                  ),
                ).then((result) async {
                  if (result == "1") {
                    setState(() {});
                  }
                });
              },
              backgroundColor: Colors.black,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
