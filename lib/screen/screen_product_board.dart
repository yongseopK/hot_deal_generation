// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_add_product.dart';

class ProductBoard extends StatefulWidget {
  const ProductBoard({Key? key, this.data}) : super(key: key);

  final String? data;

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

  void navigateToAddProduct(String data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProduct(data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    final title = ProductBoard.dataToTitle[widget.data];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: title != null ? Text(title) : null,
      ),
      body: ListView.builder(
        itemCount: 15, // 게시물 개수에 맞게 조정
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // _navigateToPostDetail(context, index);
            },
            child: Card(
              margin: const EdgeInsets.all(2.0),
              child: ListTile(
                leading: Image.asset(
                  'images/fifalogo.png', // 게시물 이미지
                  width: width * 0.1,
                  height: height * 0.1,
                  // fit: BoxFit.cover,
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
      floatingActionButton:
          loggedUser != null ? buildFloatingActionButton(widget.data) : null,
    );
  }

  FloatingActionButton buildFloatingActionButton(String? data) {
    if (data != null) {
      final title = ProductBoard.dataToTitle[data];
      return FloatingActionButton(
        onPressed: () {
          if (title != null) {
            navigateToAddProduct(data);
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      );
    }
    return const FloatingActionButton(onPressed: null);
  }
}
