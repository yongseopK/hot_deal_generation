// ignore_for_file: no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key, required this.documentId}) : super(key: key);

  final String documentId;
  @override
  State<ProductDetail> createState() =>
      _ProductDetailState(documentId: documentId);
}

class _ProductDetailState extends State<ProductDetail> {
  final String documentId;
  static String result = "1";

  String title = '';
  String text = '';
  String image = '';
  String userName = '';
  String date = '';
  String time = '';
  int intViewCount = 0;
  String viewCount = '';
  List<String> recommendInfo = [];
  List<String> imageUrls = [];

  String commentText = '';
  DocumentSnapshot? document;
  List<String> commentList = [];

  int numberOfDocument = 0;

  _ProductDetailState({required this.documentId});

  @override
  void initState() {
    super.initState();
    getPostDetails();
    print(title);
  }

  Future<void> getPostDetails() async {
    try {
      document = await FirebaseFirestore.instance
          .collection('Product')
          .doc(widget.documentId) // documentId 사용
          .get();

      if (document!.exists) {
        final dynamic rawData = document!['recommendInfo'];
        recommendInfo = List<String>.from(rawData ?? []);
        setState(() {
          title = document?['title'];
          text = document?['text'];
          image = document?['imageUrls'] != null &&
                  document!['imageUrls'].isNotEmpty
              ? document!['imageUrls'][0]
              : '';
          userName = document?['userName'];
          date = document?['date'];
          time = document?['time'];
          intViewCount = document?['viewCount'];
          viewCount = intViewCount.toString();

          imageUrls = List<String>.from(document!['imageUrls'] ?? []);

          print(imageUrls.length);
        });
      } else {
        // 게시물을 찾을 수 없을 때 처리 (예: 삭제된 게시물)
        // 필요에 따라 에러 메시지를 출력하거나 다른 작업을 수행
        print('게시물을 찾을 수 없습니다.');
      }
    } on FirebaseAuthException catch (e) {
      print('게시물 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: 0.0,
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, result);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: const Center(
          child: Text(
            "여긴 상품 정보 페이지",
          ),
        ),
      ),
    );
  }
}
