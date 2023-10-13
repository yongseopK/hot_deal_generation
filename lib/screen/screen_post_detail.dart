// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({Key? key, required this.documentId}) : super(key: key);
  // final int postIndex;
  final String documentId;

  @override
  State<PostDetailPage> createState() =>
      // ignore: no_logic_in_create_state
      _PostDetailPageState(documentId: documentId);
}

class _PostDetailPageState extends State<PostDetailPage> {
  final String documentId;
  static String result = "1";

  _PostDetailPageState({required this.documentId});

  String title = '';
  String text = '';
  String image = '';
  String userName = '';
  String time = '';

  @override
  void initState() {
    super.initState();
    // 게시물 정보를 가져오는 비동기 함수 호출
    getPostDetails();
  }

  Future<void> getPostDetails() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('BulletinBoard')
          .doc(widget.documentId) // documentId 사용
          .get();

      if (document.exists) {
        setState(() {
          title = document['title'];
          text = document['text'];
          image =
              document['imageUrls'] != null && document['imageUrls'].isNotEmpty
                  ? document['imageUrls'][0]
                  : '';
          userName = document['userName'];
          time = document['time'];
        });
      } else {
        // 게시물을 찾을 수 없을 때 처리 (예: 삭제된 게시물)
        // 필요에 따라 에러 메시지를 출력하거나 다른 작업을 수행
        print('게시물을 찾을 수 없습니다.');
      }
    } catch (e) {
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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, result);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: Column(
          children: [
            Text('내용: $text'),
            if (image.isNotEmpty) Image.network(image),
            Text('작성자: $userName', style: const TextStyle(color: Colors.grey)),
            Text('게시일: $time', style: const TextStyle(color: Colors.grey)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.abc))
          ],
        ),
      ),
    );
  }
}
